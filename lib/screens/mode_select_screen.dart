import 'package:flutter/material.dart';
import '../widgets/mode_card.dart';
import 'learn_seeing_screen.dart';
import 'learn_doing_screen.dart';
import 'learning_hub_screen.dart';

class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a mode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ModeCard(
              icon: Icons.visibility,
     
              title: 'Learn by Seeing',
              description: 'Watch gestures and understand them',
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LearningHubScreen(),
                ),
              );
            },
            ),
            const SizedBox(height: 16),
            ModeCard(
              icon: Icons.back_hand,
              title: 'Learn by Doing',
              description: 'Practice gestures with your hands',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearnDoingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
