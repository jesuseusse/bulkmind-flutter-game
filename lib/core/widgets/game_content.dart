import 'package:flutter/material.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class GameContent extends StatelessWidget {
  final int level;
  final String? time;
  final Widget? title;
  final Widget feedbackIcon;
  final Widget question;
  final Widget options;

  const GameContent({
    super.key,
    required this.level,
    this.time,
    this.title,
    required this.feedbackIcon,
    required this.question,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${localizations.level}: $level',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (time != null) ...[
              Text(
                '${localizations.time}: $time',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ] else
              const SizedBox(height: 8),
            const SizedBox(height: 16),
            if (title != null) title!,
            feedbackIcon,
            const SizedBox(height: 120),
            question,
            const SizedBox(height: 32),
            options,
          ],
        ),
      ),
    );
  }
}
