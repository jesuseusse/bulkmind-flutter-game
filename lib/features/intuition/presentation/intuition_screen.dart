import 'package:flutter/material.dart';
import 'package:mind_builder/core/widgets/base_scaffold.dart';
import 'package:mind_builder/features/intuition/presentation/providers/intuition_game_provider.dart';
import 'package:mind_builder/features/intuition/presentation/widgets/answer_feedback_icon.dart';
import 'package:mind_builder/features/intuition/presentation/widgets/color_option_button.dart';
import 'package:mind_builder/l10n/app_localizations.dart';
import 'package:mind_builder/core/utils/app_localizations_utils.dart';
import 'package:provider/provider.dart';

class IntuitionScreen extends StatelessWidget {
  const IntuitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntuitionGameProvider(),
      child: Consumer<IntuitionGameProvider>(
        builder: (context, gameProvider, child) {
          final localizations = AppLocalizations.of(context)!;

          final Widget feedbackIcon = AnswerFeedbackIcon(
            // Use a key that changes with the game's actual state
            // This ensures the icon widget is correctly re-built/updated
            // when the level changes or when the icon needs to be shown/hidden.
            key: ValueKey(
              'feedback_icon_${gameProvider.levelNumber}_${gameProvider.showCorrectIconFeedback}',
            ),
            isVisible:
                gameProvider.showCorrectIconFeedback, // Directly from provider
            isCorrect: true, // It's for correct feedback
          );

          if (gameProvider.isLoading || gameProvider.game == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final game = gameProvider.game!;
          final colorName = getColorName(game.wordKey, localizations);

          return BaseScaffold(
            title: localizations.intuition,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Level: ${gameProvider.levelNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Time: ${gameProvider.elapsedTimeFormatted}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    Text(
                      "🤔",
                      style: TextStyle(
                        fontSize: 48,
                        color: game.displayedColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    feedbackIcon,
                    const SizedBox(height: 120),
                    Text(
                      colorName,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: game.displayedColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ColorOptionButton(
                                key: ValueKey(
                                  '${game.displayedColor.toARGB32()}-${game.wordKey}-0',
                                ),
                                color: game.options[0],
                                isCorrect:
                                    game.options[0] == game.displayedColor,
                                onFinished: () => gameProvider.handleAnswer(
                                  game.options[0],
                                  context,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ColorOptionButton(
                                key: ValueKey(
                                  '${game.displayedColor.toARGB32()}-${game.wordKey}-1',
                                ),
                                color: game.options[1],
                                isCorrect:
                                    game.options[1] == game.displayedColor,
                                onFinished: () => gameProvider.handleAnswer(
                                  game.options[1],
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ColorOptionButton(
                                key: ValueKey(
                                  '${game.displayedColor.toARGB32()}-${game.wordKey}-2',
                                ),
                                color: game.options[2],
                                isCorrect:
                                    game.options[2] == game.displayedColor,
                                onFinished: () => gameProvider.handleAnswer(
                                  game.options[2],
                                  context,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ColorOptionButton(
                                key: ValueKey(
                                  '${game.displayedColor.toARGB32()}-${game.wordKey}-3',
                                ),
                                color: game.options[3],
                                isCorrect:
                                    game.options[3] == game.displayedColor,
                                onFinished: () => gameProvider.handleAnswer(
                                  game.options[3],
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
