import 'package:flutter/material.dart';
import 'package:mind_builder/features/intuition/presentation/providers/intuition_game_provider.dart';
import 'package:mind_builder/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mind_builder/features/intuition/presentation/widgets/color_option_button.dart';
import 'package:mind_builder/core/utils/app_localizations_utils.dart';

class IntuitionScreen extends StatelessWidget {
  const IntuitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntuitionGameProvider(),
      child: Consumer<IntuitionGameProvider>(
        builder: (context, gameProvider, child) {
          final localizations = AppLocalizations.of(context)!;

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

          // Use a ValueKey based on the game's unique identifier or its displayed color
          // to force ColorOptionButton to rebuild.
          // Using the displayedColor or wordKey for the game itself is effective.
          final Widget gameContent = Column(
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
              const SizedBox(height: 16),
              Text(
                "🤔",
                style: TextStyle(fontSize: 48, color: game.displayedColor),
                textAlign: TextAlign.center,
              ),
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
                          // KEY IS HERE: Use a key that changes with the game's state
                          // A combination of game.displayedColor.value and game.wordKey
                          // creates a sufficiently unique key for each game state.
                          // A better approach if you have a game ID would be ValueKey(game.id).
                          key: ValueKey(
                            '${game.displayedColor.toARGB32()}-${game.wordKey}-0',
                          ),
                          color: game.options[0],
                          isCorrect: game.options[0] == game.displayedColor,
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
                          isCorrect: game.options[1] == game.displayedColor,
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
                          isCorrect: game.options[2] == game.displayedColor,
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
                          isCorrect: game.options[3] == game.displayedColor,
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
          );

          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: gameContent, // Wrap in a variable for slight cleanliness
              ),
            ),
          );
        },
      ),
    );
  }
}
