import 'package:flutter/material.dart';

import 'package:bulkmind/l10n/app_localizations.dart';

/// Global back navigation button with localized label and back icon.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_back, size: 32),
          const SizedBox(height: 4),
          Text(localizations.back),
        ],
      ),
    );
  }
}
