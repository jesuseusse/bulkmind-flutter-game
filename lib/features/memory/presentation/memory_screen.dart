import 'package:flutter/material.dart';
import 'package:mind_builder/core/widgets/base_scaffold.dart';
import 'package:mind_builder/l10n/app_localizations.dart';

class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: AppLocalizations.of(context)!.memory,
      body: const Center(
        child: Text(
          'Memory game coming soon...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
