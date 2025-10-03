import 'package:bulkmind/core/widgets/countdown_progress_indicator.dart';
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
          return StreamBuilder<int>(
            stream: Stream.periodic(
              const Duration(milliseconds: 100),
              (x) => x,
            ),
            builder: (context, _) {
              int totalRows = patternsProvider.rows;
              int totalColumns = patternsProvider.columns;
              if (patternsProvider.startTime == null) {
                return const SizedBox.shrink();
              }

              Duration differenceTime = patternsProvider.elapsedLevelTime;
              bool isTouchedAnyCell = patternsProvider.userPattern.any(
                (row) => row.any((cell) => cell == true),
              );
              bool showPattern = patternsProvider.isInMemorizationPhase(
                differenceTime,
              );

              // Remaining level time as a 0-1 fraction for progress indicator.
              double levelRemainingTime = patternsProvider
                  .levelRemainingTimeFraction(elapsed: differenceTime);
              final double clampedLevelRemainingTime = levelRemainingTime
                  .clamp(0.0, 1.0)
                  .toDouble();

              if (!patternsProvider.hasShownTimeoutDialog &&
                  levelRemainingTime <= 0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!patternsProvider.hasShownTimeoutDialog) {
                    patternsProvider.showGameOverDialog(context);
                  }
                });
              }

              return BaseScaffold(
                title: AppLocalizations.of(context)!.patterns,
                body: GameContent(
                  level: patternsProvider.level,
                  title: Column(
                    children: [
                      LinearProgressIndicator(
                        value: clampedLevelRemainingTime, // 1→0 countdown
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade800,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  feedbackIcon: patternsProvider.showCorrectIconFeedback
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        )
                      : const SizedBox(height: 48),
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
                            showPattern: !isTouchedAnyCell && showPattern,
                            isRightAnswer:
                                patternsProvider.showCorrectIconFeedback,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
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
    required this.isRightAnswer,
  });

  final PatternsProvider patternsProvider;
  final int row;
  final int col;
  final bool showPattern;
  final bool isRightAnswer;

  @override
  Widget build(BuildContext context) {
    final bool isInitialPatternActive =
        patternsProvider.initialPattern[row][col];
    final bool isUserPatternActive = patternsProvider.userPattern[row][col];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () {
            // if (showPattern) {
            //   patternsProvider.startTime = DateTime.now().subtract(
            //     Duration(seconds: (patternsProvider.maxTime * 0.5).toInt() + 1),
            //   );
            // }
            patternsProvider.handleCellTap(row, col, context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _backgroundColor(
              isInitialPatternActive,
              isUserPatternActive,
            ),
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            minimumSize: const Size.fromHeight(60),
          ),
          child: isUserPatternActive
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final double size = patternsProvider.level < 5
                        ? 48
                        : (constraints.maxWidth < constraints.maxHeight
                              ? constraints.maxWidth * 0.6
                              : constraints.maxHeight * 0.6);
                    return Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: size,
                      ),
                    );
                  },
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

    if (isRightAnswer) {
      return inactiveColor;
    }

    if (showPattern) {
      return isInitialPatternActive ? Colors.green : inactiveColor;
    }

    return isUserPatternActive ? Colors.green : inactiveColor;
  }
}
