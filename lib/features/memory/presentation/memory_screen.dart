import 'package:flutter/material.dart';
import 'package:mind_builder/core/widgets/base_scaffold.dart';
import 'package:mind_builder/core/widgets/game_content.dart';
import 'package:mind_builder/features/memory/providers/memory_provider.dart';
import 'package:mind_builder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MemoryScreen extends StatelessWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MemoryProvider(),
      child: Consumer<MemoryProvider>(
        builder: (context, memoryProvider, _) {
          return StreamBuilder<int>(
            stream: Stream.periodic(
              const Duration(milliseconds: 100),
              (x) => x,
            ),
            builder: (context, snapshot) {
              int totalRows = memoryProvider.rows;
              int totalColumns = memoryProvider.columns;
              bool showPattern =
                  memoryProvider.startTime != null &&
                  DateTime.now()
                          .difference(memoryProvider.startTime!)
                          .inSeconds <
                      memoryProvider.maxTime * 0.5;
              return BaseScaffold(
                title: AppLocalizations.of(context)!.memory,
                body: GameContent(
                  level: memoryProvider.level,
                  time: memoryProvider.elapsedTotalTimeFormatted,
                  title: LinearProgressIndicator(
                    value:
                        1 -
                        (DateTime.now()
                                .difference(memoryProvider.startTime!)
                                .inMilliseconds /
                            (memoryProvider.maxTime *
                                1000)), // progress decreases from 1 to 0
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade800,
                    color: Colors.green,
                  ),
                  feedbackIcon: memoryProvider.showCorrectIconFeedback
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
                                  memoryProvider.startTime = DateTime.now()
                                      .subtract(
                                        Duration(
                                          seconds:
                                              (memoryProvider.maxTime * 0.5)
                                                  .toInt() +
                                              1,
                                        ),
                                      );
                                }
                                memoryProvider.handleCellTap(row, col, context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: showPattern
                                    ? (memoryProvider.initialPattern[row][col]
                                          ? Colors.green
                                          : Colors.grey.shade800)
                                    : (memoryProvider.userPattern[row][col]
                                          ? Colors.green
                                          : Colors.grey.shade800),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                minimumSize: const Size.fromHeight(60),
                              ),
                              child: memoryProvider.userPattern[row][col]
                                  ? LayoutBuilder(
                                      builder: (context, constraints) {
                                        final size = memoryProvider.level < 5
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
