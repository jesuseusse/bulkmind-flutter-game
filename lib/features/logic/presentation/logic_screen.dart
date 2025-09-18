import 'package:flutter/material.dart';
import 'package:bulkmind/core/widgets/game_option_button.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bulkmind/core/widgets/base_scaffold.dart';
import 'package:bulkmind/core/widgets/game_content.dart';
import 'package:bulkmind/features/logic/presentation/providers/logic_provider.dart';
import 'package:bulkmind/features/intuition/presentation/widgets/answer_feedback_icon.dart';

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
              question: Icon(
                logicProvider.puzzle['question'] == '>'
                    ? Icons.trending_down
                    : Icons.trending_up,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              options: [
                Row(
                  children: [
                    GameOptionButton(
                      value: logicProvider.puzzle['options'][0],
                      isPressed: logicProvider.pressed.contains(
                        logicProvider.puzzle['options'][0],
                      ),
                      onPressed: () {
                        logicProvider.selectOption(
                          logicProvider.puzzle['options'][0],
                          context,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    GameOptionButton(
                      value: logicProvider.puzzle['options'][1],
                      isPressed: logicProvider.pressed.contains(
                        logicProvider.puzzle['options'][1],
                      ),
                      onPressed: () {
                        logicProvider.selectOption(
                          logicProvider.puzzle['options'][1],
                          context,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GameOptionButton(
                      value: logicProvider.puzzle['options'][2],
                      isPressed: logicProvider.pressed.contains(
                        logicProvider.puzzle['options'][2],
                      ),
                      onPressed: () {
                        logicProvider.selectOption(
                          logicProvider.puzzle['options'][2],
                          context,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    GameOptionButton(
                      value: logicProvider.puzzle['options'][3],
                      isPressed: logicProvider.pressed.contains(
                        logicProvider.puzzle['options'][3],
                      ),
                      onPressed: () {
                        logicProvider.selectOption(
                          logicProvider.puzzle['options'][3],
                          context,
                        );
                      },
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
