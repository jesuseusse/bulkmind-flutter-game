import 'package:flutter/material.dart';
import 'package:mind_builder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mind_builder/core/widgets/base_scaffold.dart';
import 'package:mind_builder/core/widgets/game_content.dart';
import 'package:mind_builder/features/logic/presentation/providers/logic_provider.dart';
import 'package:mind_builder/features/intuition/presentation/widgets/answer_feedback_icon.dart';

class LogicScreen extends StatelessWidget {
  const LogicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LogicProvider(),
      child: Consumer<LogicProvider>(
        builder: (context, logicProvider, _) {
          final localizations = AppLocalizations.of(context)!;

          final Widget feedbackIcon = AnswerFeedbackIcon(
            key: ValueKey(
              'feedback_icon_${logicProvider.level}_${logicProvider.showCorrectIconFeedback}',
            ),
            isVisible: logicProvider.showCorrectIconFeedback,
            isCorrect: true,
          );

          return BaseScaffold(
            title: localizations.logic,
            body: GameContent(
              level: logicProvider.level,
              time: logicProvider.elapsedTimeFormatted,
              feedbackIcon: feedbackIcon,
              question: Text(
                logicProvider.puzzle['question'],
                style: const TextStyle(fontSize: 48, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              options: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: ValueKey(
                          logicProvider.puzzle['options'][0].toString(),
                        ),
                        onPressed:
                            logicProvider.pressed.contains(
                              logicProvider.puzzle['options'][0],
                            )
                            ? null
                            : () {
                                logicProvider.selectOption(
                                  logicProvider.puzzle['options'][0],
                                  context,
                                );
                              },
                        child: Text(
                          logicProvider.puzzle['options'][0].toString(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        key: ValueKey(
                          logicProvider.puzzle['options'][1].toString(),
                        ),
                        onPressed:
                            logicProvider.pressed.contains(
                              logicProvider.puzzle['options'][1],
                            )
                            ? null
                            : () {
                                logicProvider.selectOption(
                                  logicProvider.puzzle['options'][1],
                                  context,
                                );
                              },
                        child: Text(
                          logicProvider.puzzle['options'][1].toString(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        key: ValueKey(
                          logicProvider.puzzle['options'][2].toString(),
                        ),
                        onPressed:
                            logicProvider.pressed.contains(
                              logicProvider.puzzle['options'][2],
                            )
                            ? null
                            : () {
                                logicProvider.selectOption(
                                  logicProvider.puzzle['options'][2],
                                  context,
                                );
                              },
                        child: Text(
                          logicProvider.puzzle['options'][2].toString(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        key: ValueKey(
                          logicProvider.puzzle['options'][3].toString(),
                        ),
                        onPressed:
                            logicProvider.pressed.contains(
                              logicProvider.puzzle['options'][3],
                            )
                            ? null
                            : () {
                                logicProvider.selectOption(
                                  logicProvider.puzzle['options'][3],
                                  context,
                                );
                              },
                        child: Text(
                          logicProvider.puzzle['options'][3].toString(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
