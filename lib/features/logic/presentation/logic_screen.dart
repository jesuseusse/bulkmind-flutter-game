import 'package:bulkmind/core/widgets/timed_display.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:bulkmind/core/widgets/base_scaffold.dart';
import 'package:bulkmind/core/widgets/countdown_progress_indicator.dart';
import 'package:bulkmind/core/widgets/game_content.dart';
import 'package:bulkmind/core/widgets/game_option_button.dart';
import 'package:bulkmind/features/logic/presentation/providers/logic_game_provider.dart';
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
              //show when level > 0
              feedbackIcon: (logicProvider.level) > 0
                  ? TimedDisplay(
                      key: ValueKey('timed_display_${logicProvider.level}'),
                      duration: const Duration(milliseconds: 500),
                      child: const Text('✅', style: TextStyle(fontSize: 48)),
                    )
                  : null,
              question: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountdownProgressIndicator(
                    key: ValueKey(
                      'logic_timer_${logicProvider.level}_${logicProvider.maxTimeOut.inMilliseconds}_${logicProvider.options.join(',')}',
                    ),
                    duration: logicProvider.maxTimeOut,
                    onCompleted: () {
                      logicProvider.maxTimeOut > Duration.zero
                          ? logicProvider.onTimeOut(context)
                          : null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Icon(
                    logicProvider.question == '>'
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
                            logicProvider.handleAnswer(options[0], context),
                      ),
                      const SizedBox(width: 16),
                      GameOptionButton(
                        value: options[1],
                        isPressed: logicProvider.isOptionPressed(options[1]),
                        onPressed: () =>
                            logicProvider.handleAnswer(options[1], context),
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
                            logicProvider.handleAnswer(options[2], context),
                      ),
                      const SizedBox(width: 16),
                      GameOptionButton(
                        value: options[3],
                        isPressed: logicProvider.isOptionPressed(options[3]),
                        onPressed: () =>
                            logicProvider.handleAnswer(options[3], context),
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
