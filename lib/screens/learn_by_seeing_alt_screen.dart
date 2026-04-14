import 'package:flutter/material.dart';

class LearnBySeeingAltScreen extends StatelessWidget {
  const LearnBySeeingAltScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gestures = [
      {
        "title": "A",
        "desc": "Make a fist, thumb resting on the side.",
        "img": "assets/gestures/A.png",
      },
      {
        "title": "B",
        "desc": "Palm open, fingers straight and together.",
        "img": "assets/gestures/B.png",
      },
      {
        "title": "C",
        "desc": "Curve your fingers to form a C shape.",
        "img": "assets/gestures/C.png",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn by Seeing (Alternate)"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: gestures.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final g = gestures[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                g["img"]!,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Letter ${g["title"]}",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      g["desc"]!,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
