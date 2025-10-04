import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:bulkmind/core/widgets/base_scaffold.dart';
import 'package:bulkmind/core/widgets/countdown_progress_indicator.dart';
import 'package:bulkmind/core/widgets/game_content.dart';
import 'package:bulkmind/core/widgets/game_option_button.dart';
import 'package:bulkmind/features/intuition/presentation/widgets/answer_feedback_icon.dart';
import 'package:bulkmind/features/logic/presentation/providers/logic_provider.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

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

          final options = logicProvider.options;

          if (options.length < 4) {
            return BaseScaffold(
              title: localizations.logic,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return BaseScaffold(
            title: localizations.logic,
            body: GameContent(
              level: logicProvider.level,
              time: logicProvider.elapsedTimeFormatted,
              feedbackIcon: feedbackIcon,
              question: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountdownProgressIndicator(
                    key: ValueKey(
                      'logic_timer_${logicProvider.level}_${logicProvider.timeLimit.inMilliseconds}_${logicProvider.timerSeed}',
                    ),
                    duration: logicProvider.timeLimit,
                    onCompleted: () =>
                        logicProvider.handleTimeout(context),
                  ),
                  const SizedBox(height: 24),
                  Icon(
                    logicProvider.comparisonSymbol == '>'
                        ? Icons.trending_down
                        : Icons.trending_up,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
              options: Column(
                children: [
                  Row(
                    children: [
                      GameOptionButton(
                        value: options[0],
                        isPressed: logicProvider.isOptionPressed(options[0]),
                        onPressed: () =>
                            logicProvider.selectOption(options[0], context),
                      ),
                      const SizedBox(width: 16),
                      GameOptionButton(
                        value: options[1],
                        isPressed: logicProvider.isOptionPressed(options[1]),
                        onPressed: () =>
                            logicProvider.selectOption(options[1], context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      GameOptionButton(
                        value: options[2],
                        isPressed: logicProvider.isOptionPressed(options[2]),
                        onPressed: () =>
                            logicProvider.selectOption(options[2], context),
                      ),
                      const SizedBox(width: 16),
                      GameOptionButton(
                        value: options[3],
                        isPressed: logicProvider.isOptionPressed(options[3]),
                        onPressed: () =>
                            logicProvider.selectOption(options[3], context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
