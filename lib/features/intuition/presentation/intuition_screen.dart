import 'package:bulkmind/core/widgets/countdown_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:bulkmind/core/widgets/base_scaffold.dart';
import 'package:bulkmind/core/widgets/game_content.dart';
import 'package:bulkmind/features/intuition/presentation/providers/intuition_game_provider.dart';
import 'package:bulkmind/features/intuition/presentation/widgets/answer_feedback_icon.dart';
import 'package:bulkmind/features/intuition/presentation/widgets/color_option_button.dart';
import 'package:bulkmind/features/intuition/domain/entities/color_game_data.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:bulkmind/core/utils/app_localizations_utils.dart';
import 'package:provider/provider.dart';

class IntuitionScreen extends StatefulWidget {
  const IntuitionScreen({super.key});

  @override
  State<IntuitionScreen> createState() => _IntuitionScreenState();
}

class _IntuitionScreenState extends State<IntuitionScreen> {
  bool _optionsLocked = false;
  ColorGameData? _currentGame;

  void _lockOptions() {
    if (_optionsLocked) return;
    setState(() {
      _optionsLocked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => IntuitionGameProvider(),
      child: Consumer<IntuitionGameProvider>(
        builder: (context, gameProvider, child) {
          final game = gameProvider.game;

          if (_currentGame != game && game != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _currentGame = game;
                _optionsLocked = false;
              });
            });
          }

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

          if (gameProvider.isLoading || game == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          final colorName = getColorName(game.wordKey, localizations);

          return BaseScaffold(
            title: localizations.intuition,
            body: GameContent(
              level: gameProvider.levelNumber,
              title: Column(
                children: [
                  _optionsLocked
                      ? const SizedBox(height: 8)
                      : CountdownProgressIndicator(
                          key: ValueKey(
                            '${gameProvider.levelNumber}_${game.wordKey}',
                          ),
                          duration: game.timeLimit ?? Duration(seconds: 0),
                          onCompleted: () =>
                              gameProvider.showGameOverTimeOut(context),
                        ),
                  const SizedBox(height: 8),
                  Text("🤔", style: TextStyle(fontSize: 24)),
                ],
              ),
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
              options: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ColorOptionButton(
                          key: ValueKey(
                            '${game.displayedColor.toARGB32()}-${game.wordKey}-0',
                          ),
                          color: game.options[0],
                          isCorrect: game.options[0] == game.displayedColor,
                          onSelected: _lockOptions,
                          onFinished: () => gameProvider.handleAnswer(
                            game.options[0],
                            context,
                          ),
                          isEnabled: !_optionsLocked,
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
                          onSelected: _lockOptions,
                          onFinished: () => gameProvider.handleAnswer(
                            game.options[1],
                            context,
                          ),
                          isEnabled: !_optionsLocked,
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
                          onSelected: _lockOptions,
                          onFinished: () => gameProvider.handleAnswer(
                            game.options[2],
                            context,
                          ),
                          isEnabled: !_optionsLocked,
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
                          onSelected: _lockOptions,
                          onFinished: () => gameProvider.handleAnswer(
                            game.options[3],
                            context,
                          ),
                          isEnabled: !_optionsLocked,
                        ),
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
