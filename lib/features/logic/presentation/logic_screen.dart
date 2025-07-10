import 'package:flutter/material.dart';
import 'package:mind_builder/core/widgets/base_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_builder/l10n/app_localizations.dart';

class LogicScreen extends StatelessWidget {
  const LogicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: AppLocalizations.of(context)!.logic,
      body: const Center(
        child: Text(
          'Logic game coming soon...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
