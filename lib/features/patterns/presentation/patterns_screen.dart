import 'package:bulkmind/core/widgets/countdown_progress_indicator.dart';
import 'package:bulkmind/core/widgets/timed_display.dart';
import 'package:flutter/material.dart';
import 'package:bulkmind/core/widgets/base_scaffold.dart';
import 'package:bulkmind/core/widgets/game_content.dart';
import 'package:bulkmind/features/patterns/providers/patterns_provider.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PatternsScreen extends StatelessWidget {
  const PatternsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PatternsProvider(),
      child: Consumer<PatternsProvider>(
        builder: (context, patternsProvider, _) {
          if (patternsProvider.startTime == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final int totalRows = patternsProvider.rows;
          final int totalColumns = patternsProvider.columns;

          return BaseScaffold(
            title: AppLocalizations.of(context)!.patterns,
            body: GameContent(
              level: patternsProvider.level,
              title: Column(
                children: [
                  CountdownProgressIndicator(
                    key: ValueKey(
                      '${patternsProvider.level}_${patternsProvider.maxTimeOut.inMilliseconds}',
                    ),
                    duration: patternsProvider.maxTimeOut,
                    onCompleted: () {
                      patternsProvider.onTimeOut(context);
                    },
                  ),
                ],
              ),
              feedbackIcon: (patternsProvider.level) > 0
                  ? TimedDisplay(
                      key: ValueKey('timed_display_${patternsProvider.level}'),
                      duration: const Duration(milliseconds: 500),
                      child: const Text('✅'),
                    )
                  : null,
              question: const SizedBox(),
              options: Column(
                children: List.generate(
                  totalRows,
                  (row) => Row(
                    children: List.generate(
                      totalColumns,
                      (col) => _PatternCell(
                        patternsProvider: patternsProvider,
                        row: row,
                        col: col,
                        showPattern: patternsProvider.showPattern,
                        disableInteraction:
                            patternsProvider.hasShownTimeoutDialog,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PatternCell extends StatelessWidget {
  const _PatternCell({
    required this.patternsProvider,
    required this.row,
    required this.col,
    required this.showPattern,
    required this.disableInteraction,
  });

  final PatternsProvider patternsProvider;
  final int row;
  final int col;
  final bool showPattern;
  final bool disableInteraction;

  @override
  Widget build(BuildContext context) {
    final bool isGamePatternActive = patternsProvider.gamePattern[row][col];
    final bool isUserPatternActive = patternsProvider.userPattern[row][col];
    final bool isPatternCorrect = isGamePatternActive && isUserPatternActive;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () {
            if (!disableInteraction) {
              patternsProvider.handleCellTap(row, col, context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _backgroundColor(
              isGamePatternActive,
              isUserPatternActive,
            ),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            minimumSize: const Size.fromHeight(60),
          ),
          child: isUserPatternActive
              ? Center(
                  child: !isPatternCorrect
                      ? Icon(
                          Icons.cancel,
                          color: Colors.red,

                          applyTextScaling: true,
                        )
                      : Icon(
                          Icons.check_circle,
                          color: Colors.white,

                          applyTextScaling: true,
                        ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Color _backgroundColor(
    bool isInitialPatternActive,
    bool isUserPatternActive,
  ) {
    final Color inactiveColor = Colors.grey.shade800;

    if (showPattern) {
      return isInitialPatternActive ? Colors.green : inactiveColor;
    }

    return isUserPatternActive ? Colors.green : inactiveColor;
  }
}
