import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class LearnDoingScreen extends StatefulWidget {
  const LearnDoingScreen({super.key});

  @override
  State<LearnDoingScreen> createState() => _LearnDoingScreenState();
}

class _LearnDoingScreenState extends State<LearnDoingScreen> {
  CameraController? _controller;
  bool isCameraReady = false;

  String currentTarget = "A";
  String detected = "None";

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();

    setState(() {
      isCameraReady = true;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void simulateDetection() {
    setState(() {
      detected = currentTarget; // fake correct detection
    });
  }

  void nextLetter() {
    setState(() {
      if (currentTarget == "A") currentTarget = "B";
      else if (currentTarget == "B") currentTarget = "C";
      else currentTarget = "A";

      detected = "None";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn by Doing"),
      ),
      body: isCameraReady
          ? Stack(
              children: [
                // 📷 Camera Preview
                CameraPreview(_controller!),

                // 🎯 Target Gesture (Top)
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Show gesture for: $currentTarget",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // ✅ Detection Result (Center)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Detected: $detected",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // 🔘 Controls (Bottom)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: simulateDetection,
                        child: const Text("Simulate"),
                      ),
                      ElevatedButton(
                        onPressed: nextLetter,
                        child: const Text("Next"),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}