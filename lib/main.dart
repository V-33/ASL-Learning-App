import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hand_painter.dart';
import 'screens/splash_screen.dart';
import 'screens/intro_screen.dart';

/*
late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

/* ============================================================
   KNN DATA STRUCTURE (TOP LEVEL)
   ============================================================ */
class KNNExample {
  final List<double> features;
  final String label;

  KNNExample(this.features, this.label);

  Map<String, dynamic> toJson() => {
        'label': label,
        'features': features,
      };

  factory KNNExample.fromJson(Map<String, dynamic> json) {
    return KNNExample(
      List<double>.from(json['features']),
      json['label'],
    );
  }
}

/* ============================================================
   APP
   ============================================================ */
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  static const MethodChannel _channel = MethodChannel('hand_detector');

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  bool _isStreaming = false;
  DateTime _lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  List<double> _landmarks = [];
  List<double>? _lastValidLandmarks;

  String _detectedLetter = "No Letter";
  double _confidence = 0.0;

  double _handPresence = 0.0;

  final List<KNNExample> _dataset = [];
  String _selectedLabel = "A";

  /* ============================================================
     INIT
     ============================================================ */
  @override
  void initState() {
    super.initState();

    _loadDataset();

    final cam =
        cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front);

    _controller = CameraController(
      cam,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    _initializeControllerFuture = _controller.initialize().then((_) {
      _startImageStream();
    });

    _channel.setMethodCallHandler((call) async {
      if (call.method == "onHandLandmarks") {
        final raw = call.arguments as List<dynamic>;
        final lm = raw.map((e) => (e as num).toDouble()).toList();

        // Debug print
        print("Landmarks received: ${lm.length}");

        if (lm.length == 63) {
          _lastValidLandmarks = lm;
          _landmarks = lm;
          _handPresence = (_handPresence + 0.3).clamp(0.0, 1.0);
        } else if (_lastValidLandmarks != null) {
          _landmarks = _lastValidLandmarks!;
          _handPresence = (_handPresence - 0.05).clamp(0.0, 1.0);
        } else {
          _handPresence = (_handPresence - 0.05).clamp(0.0, 1.0);
        }

        setState(() {}); // repaint
      }
    });

  }

  /* ============================================================
     SAVE/LOAD DATASET
     ============================================================ */
  Future<void> _saveDataset() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr =
        jsonEncode(_dataset.map((e) => e.toJson()).toList());
    await prefs.setString('knn_dataset', jsonStr);
  }

  Future<void> _loadDataset() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('knn_dataset');
    if (jsonStr != null) {
      final List<dynamic> list = jsonDecode(jsonStr);
      _dataset.clear();
      _dataset.addAll(list.map((e) => KNNExample.fromJson(e)));
      setState(() {});
    }
  }

  /* ============================================================
     GEOMETRY
     ============================================================ */
  Offset p(List<double> lm, int i) => Offset(lm[i * 3], lm[i * 3 + 1]);
  double d(Offset a, Offset b) => (a - b).distance;
  double handScale(List<double> lm) => d(p(lm, 0), p(lm, 9));

  /* ============================================================
     FEATURE EXTRACTION
     ============================================================ */
 double angle(Offset a, Offset b, Offset c) {
  final ab = a - b;
  final cb = c - b;
  final dot = ab.dx * cb.dx + ab.dy * cb.dy;
  final mag = ab.distance * cb.distance + 1e-6;
  return acos((dot / mag).clamp(-1.0, 1.0));
}
double _fingerCurl(List<double> lm, int tip, int pip, int mcp) {
  final tipP = p(lm, tip);
  final pipP = p(lm, pip);
  final mcpP = p(lm, mcp);

  final a = d(tipP, pipP);
  final b = d(pipP, mcpP);

  // ratio-based curl (scale invariant)
  return (1.0 - (a / (b + 1e-6))).clamp(0.0, 1.0);
}

List<double> extractFeatures(List<double> lm) {
  return [
    // thumb
    _fingerCurl(lm, 4, 3, 2),

    // index
    _fingerCurl(lm, 8, 7, 5),

    // middle
    _fingerCurl(lm, 12, 11, 9),

    // ring
    _fingerCurl(lm, 16, 15, 13),

    // pinky
    _fingerCurl(lm, 20, 19, 17),
  ];
}

  /* ============================================================
     KNN CLASSIFICATION
     ============================================================ */
  (String, double) knnClassify(List<double> input, {int k = 3}) {
    final distances = _dataset.map((e) {
      double sum = 0;
      for (int i = 0; i < input.length; i++) {
        final diff = input[i] - e.features[i];
        sum += diff * diff;
      }
      return MapEntry(e.label, sqrt(sum));
    }).toList();

    distances.sort((a, b) => a.value.compareTo(b.value));

    final votes = <String, int>{};
    for (int i = 0; i < min(k, distances.length); i++) {
      votes[distances[i].key] =
          (votes[distances[i].key] ?? 0) + 1;
    }

    final best = votes.entries.reduce((a, b) => a.value > b.value ? a : b);
    return (best.key, best.value / k);
  }


  /* ============================================================
     CAMERA STREAM
     ============================================================ */
  void _startImageStream() {
    if (_isStreaming) return;
    _isStreaming = true;

    _controller.startImageStream((image) async {
      final now = DateTime.now();
      if (now.difference(_lastSent).inMilliseconds < 150) return;
      _lastSent = now;

      final rgb = convertYUV420ToRGB(image);

      await _channel.invokeMethod('sendFrame', {
        'width': image.width,
        'height': image.height,
        'bytes': rgb,
      });
    });
  }
  Uint8List convertYUV420ToRGB(CameraImage image) {
    final w = image.width, h = image.height;
    final y = image.planes[0].bytes;
    final u = image.planes[1].bytes;
    final v = image.planes[2].bytes;

    final out = Uint8List(w * h * 3);
    int i = 0;

    for (int y0 = 0; y0 < h; y0++) {
      for (int x0 = 0; x0 < w; x0++) {
        final yp = y[y0 * image.planes[0].bytesPerRow + x0];
        final uvp = (y0 >> 1) * image.planes[1].bytesPerRow +
            (x0 >> 1) * image.planes[1].bytesPerPixel!;
        final up = u[uvp];
        final vp = v[uvp];

        out[i++] = (yp + 1.37 * (vp - 128)).clamp(0, 255).toInt();
        out[i++] =
            (yp - 0.34 * (up - 128) - 0.69 * (vp - 128))
                .clamp(0, 255)
                .toInt();
        out[i++] = (yp + 1.73 * (up - 128)).clamp(0, 255).toInt();
      }
    }
    return out;
  }

  /* ============================================================
     UI
     ============================================================ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ASL KNN")),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              CameraPreview(_controller),
              if (_landmarks.length == 63)
                Positioned.fill(
                  child: CustomPaint(
                  painter: HandPainter(landmarks: _landmarks),
                  ),
                ),

              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    Text(
                      _handPresence < 0.3
                          ? "No hand detected"
                          : "$_detectedLetter  (${(_confidence * 100).toStringAsFixed(0)}%)",
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: ["A", "B", "C", "D", "E", "F", "G"].map((letter) {
                        final count =
                            _dataset.where((e) => e.label == letter).length;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLabel = letter;
                            });
                          },
                          onLongPress: () {
                            if (_handPresence > 0.5 && _landmarks.length == 63) {
                              final features = extractFeatures(_landmarks);
                              _dataset.add(KNNExample(features, letter));

                              print("Added sample for $letter");
                              print("DATASET SIZE = ${_dataset.length}");

                              setState(() {});
                            }
                          },
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _selectedLabel == letter ? Colors.green : null,
                            ),
                            onPressed: null, // handled by GestureDetector
                            child: Text("$letter ($count)"),
                          ),
                        );
                      }).toList(),
                    ),


                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_landmarks.length == 63) {
                          final features = extractFeatures(_landmarks);
                          _dataset.add(KNNExample(features, _selectedLabel));
                          _saveDataset();
                          setState(() {});
                        }
                      },
                      child: const Text("Add to Dataset / Train"),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

*/
void main() {
  runApp(const ASLApp());
}

class ASLApp extends StatelessWidget {
  const ASLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'ASL Learning App',
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F8F7),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF6F8F7),
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      bodyLarge: TextStyle(fontSize: 16),
    ),
  ),
  home: const IntroScreen(),
);

  }
}
