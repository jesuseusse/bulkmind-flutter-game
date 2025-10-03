import 'package:flutter/material.dart';

import 'package:bulkmind/l10n/app_localizations.dart';

/// Global retry action button with localized label and replay icon.
class RetryButton extends StatelessWidget {
  const RetryButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.replay, size: 32),
          const SizedBox(height: 4),
          Text(localizations.retry),
        ],
      ),
    );
  }
}
