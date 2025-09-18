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
            builder: (context, snapshot) {
              int totalRows = patternsProvider.rows;
              int totalColumns = patternsProvider.columns;
              bool showPattern =
                  patternsProvider.startTime != null &&
                  DateTime.now()
                          .difference(patternsProvider.startTime!)
                          .inSeconds <
                      patternsProvider.maxTime * 0.5;
              return BaseScaffold(
                title: AppLocalizations.of(context)!.patterns,
                body: GameContent(
                  level: patternsProvider.level,
                  time: patternsProvider.elapsedTotalTimeFormatted,
                  title: LinearProgressIndicator(
                    value:
                        1 -
                        (DateTime.now()
                                .difference(patternsProvider.startTime!)
                                .inMilliseconds /
                            (patternsProvider.maxTime *
                                1000)), // progress decreases from 1 to 0
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade800,
                    color: Colors.green,
                  ),
                  feedbackIcon: patternsProvider.showCorrectIconFeedback
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        )
                      : const SizedBox(height: 48),
                  question: const SizedBox(),
                  options: List.generate(
                    totalRows,
                    (row) => Row(
                      children: List.generate(
                        totalColumns,
                        (col) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                if (showPattern) {
                                  patternsProvider.startTime = DateTime.now()
                                      .subtract(
                                        Duration(
                                          seconds:
                                              (patternsProvider.maxTime * 0.5)
                                                  .toInt() +
                                              1,
                                        ),
                                      );
                                }
                                patternsProvider.handleCellTap(
                                  row,
                                  col,
                                  context,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: showPattern
                                    ? (patternsProvider.initialPattern[row][col]
                                          ? Colors.green
                                          : Colors.grey.shade800)
                                    : (patternsProvider.userPattern[row][col]
                                          ? Colors.green
                                          : Colors.grey.shade800),
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                minimumSize: const Size.fromHeight(60),
                              ),
                              child: patternsProvider.userPattern[row][col]
                                  ? LayoutBuilder(
                                      builder: (context, constraints) {
                                        final size = patternsProvider.level < 5
                                            ? 48
                                            : (constraints.maxWidth <
                                                      constraints.maxHeight
                                                  ? constraints.maxWidth * 0.6
                                                  : constraints.maxHeight *
                                                        0.6);
                                        return Center(
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: size.toDouble(),
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ),
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
