import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GestureItem {
  final String title;
  final String description;
  final String imagePath;

  GestureItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class LearnBySeeingScreen extends StatefulWidget {
  const LearnBySeeingScreen({super.key});

  @override
  State<LearnBySeeingScreen> createState() => _LearnBySeeingScreenState();
}

class _LearnBySeeingScreenState extends State<LearnBySeeingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  bool isAutoPlay = false;
  Timer? autoPlayTimer;

  final List<GestureItem> gestures = [
    GestureItem(
      title: "A",
      description: "Make a fist, thumb resting on the side.",
      imagePath: "assets/gestures/A.png",
    ),
    GestureItem(
      title: "B",
      description: "Palm open, fingers straight and together.",
      imagePath: "assets/gestures/B.png",
    ),
    GestureItem(
      title: "C",
      description: "Curve your fingers to form a C shape.",
      imagePath: "assets/gestures/C.png",
    ),
  ];

  @override
  void dispose() {
    autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void goNext() {
    if (currentIndex < gestures.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goPrevious() {
    if (currentIndex > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void repeatGesture() {
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void toggleAutoPlay() {
    HapticFeedback.mediumImpact();
    setState(() => isAutoPlay = !isAutoPlay);

    autoPlayTimer?.cancel();

    if (isAutoPlay) {
      autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (currentIndex < gestures.length - 1) {
          goNext();
        } else {
          toggleAutoPlay();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (currentIndex + 1) / gestures.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn by Seeing"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.green.shade100,
            color: Colors.green.shade700,
            minHeight: 6,
          ),

          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: gestures.length,
              onPageChanged: (index) {
                setState(() => currentIndex = index);
              },
              itemBuilder: (context, index) {
                final gesture = gestures[index];
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          "Letter ${gesture.title}",
                          key: ValueKey(gesture.title),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gesture.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Hero(
                          tag: gesture.imagePath,
                          child: Image.asset(
                            gesture.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: goPrevious,
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay),
                    onPressed: repeatGesture,
                  ),
                  IconButton(
                    icon: Icon(
                      isAutoPlay ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: toggleAutoPlay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: goNext,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "ASL images courtesy of Lifeprint & Wikimedia Commons",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
