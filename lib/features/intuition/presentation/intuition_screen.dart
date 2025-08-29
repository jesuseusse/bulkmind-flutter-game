import 'package:flutter/material.dart';
import 'package:bulkmind/core/widgets/base_scaffold.dart';
import 'package:bulkmind/core/widgets/game_content.dart';
import 'package:bulkmind/features/intuition/presentation/providers/intuition_game_provider.dart';
import 'package:bulkmind/features/intuition/presentation/widgets/answer_feedback_icon.dart';
import 'package:bulkmind/features/intuition/presentation/widgets/color_option_button.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:bulkmind/core/utils/app_localizations_utils.dart';
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
            body: GameContent(
              level: gameProvider.levelNumber,
              time: gameProvider.elapsedTimeFormatted,
              title: Text("🤔"),
              feedbackIcon: feedbackIcon,
              question: Text(
                colorName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: game.displayedColor,
                ),
                textAlign: TextAlign.center,
              ),
              options: [
                Row(
                  children: [
                    Expanded(
                      child: ColorOptionButton(
                        key: ValueKey(
                          '${game.displayedColor.toARGB32()}-${game.wordKey}-0',
                        ),
                        color: game.options[0],
                        isCorrect: game.options[0] == game.displayedColor,
                        onFinished: () =>
                            gameProvider.handleAnswer(game.options[0], context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ColorOptionButton(
                        key: ValueKey(
                          '${game.displayedColor.toARGB32()}-${game.wordKey}-1',
                        ),
                        color: game.options[1],
                        isCorrect: game.options[1] == game.displayedColor,
                        onFinished: () =>
                            gameProvider.handleAnswer(game.options[1], context),
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
                        isCorrect: game.options[2] == game.displayedColor,
                        onFinished: () =>
                            gameProvider.handleAnswer(game.options[2], context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ColorOptionButton(
                        key: ValueKey(
                          '${game.displayedColor.toARGB32()}-${game.wordKey}-3',
                        ),
                        color: game.options[3],
                        isCorrect: game.options[3] == game.displayedColor,
                        onFinished: () =>
                            gameProvider.handleAnswer(game.options[3], context),
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
