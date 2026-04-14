import 'package:flutter/material.dart';
import 'learn_seeing_screen.dart';
import 'learn_by_seeing_alt_screen.dart';
class LearningHubScreen extends StatelessWidget {
  const LearningHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP progress values (later from storage/backend)
    final double learningProgress = 0.45;
    final double practiceProgress = 0.2;
    final double testUnlockThreshold = 0.6;

    final bool testUnlocked = learningProgress >= testUnlockThreshold;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Hub"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              // TODO: Profile / Settings / Sign out
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "profile", child: Text("Profile")),
              PopupMenuItem(value: "settings", child: Text("Settings")),
              PopupMenuItem(value: "logout", child: Text("Sign Out")),
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            HubCard(
              title: "Resume Learning",
              subtitle: "Continue where you left off",
              progress: learningProgress,
              icon: Icons.play_circle_fill,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LearnBySeeingScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            HubCard(
              title: "Practice",
              subtitle: "Practice learned gestures",
              progress: practiceProgress,
              icon: Icons.fitness_center,
              onTap: () {
                // TODO: Practice screen
              },
            ),
            const SizedBox(height: 16),

            HubCard(
              title: "Test",
              subtitle: testUnlocked
                  ? "Check your knowledge"
                  : "Complete more learning to unlock",
              progress: learningProgress,
              icon: Icons.quiz,
              enabled: testUnlocked,
              onTap: testUnlocked
                  ? () {
                      // TODO: Test screen
                    }
                  : null,
            ),
            OutlinedButton.icon(
  icon: const Icon(Icons.view_list),
  label: const Text("Alternate Design"),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LearnBySeeingAltScreen(),
      ),
    );
  },
),

          ],
        ),
      ),
    );
  }
}

class HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const HubCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    super.key,
  });
  

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
  color: Colors.white,
  borderRadius: BorderRadius.circular(18),
  elevation: enabled ? 4 : 0,
  child: InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: enabled ? onTap : null,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: Colors.green.shade800),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
            ),
          ),
        ],
      ),
    ),
  ),
),
    );
  }
}
