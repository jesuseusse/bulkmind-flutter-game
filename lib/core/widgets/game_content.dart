import 'package:flutter/material.dart';

class GameContent extends StatelessWidget {
  final int level;
  final String time;
  final Widget? title;
  final Widget feedbackIcon;
  final Widget question;
  final List<Widget> options;

  const GameContent({
    super.key,
    required this.level,
    required this.time,
    this.title,
    required this.feedbackIcon,
    required this.question,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Level: $level',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Time: $time',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            if (title != null) title!,
            feedbackIcon,
            const SizedBox(height: 120),
            question,
            const SizedBox(height: 32),
            Column(children: options),
          ],
        ),
      ),
    );
  }
}
