import 'package:flutter/material.dart';
import 'package:bulkmind/core/widgets/base_scaffold.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class SpatialScreen extends StatelessWidget {
  const SpatialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: AppLocalizations.of(context)!.spatial,
      body: const Center(
        child: Text(
          'Spatial game coming soon...',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
