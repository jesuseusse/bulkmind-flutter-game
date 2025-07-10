import 'package:flutter/material.dart';
import 'package:mind_builder/core/widgets/base_scaffold.dart';
import 'package:mind_builder/l10n/app_localizations.dart';

class IntuitionScreen extends StatelessWidget {
  const IntuitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: AppLocalizations.of(context)!.intuition,
      body: const Center(
        child: Text(
          'Intuition game coming soon...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
