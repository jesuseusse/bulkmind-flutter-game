import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bulkmind/core/services/launch_service.dart';
import 'package:bulkmind/features/intuition/domain/entities/color_game_data.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:bulkmind/features/onboarding/domain/usecases/generate_color_game.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late ColorGameData game;

  @override
  void initState() {
    super.initState();
    _generateGame();
  }

  void _generateGame() {
    final pair = generateColorWordPair();
    game = ColorGameData(
      wordKey: pair.key,
      displayedColor: pair.value,
      options: generateColorOptions(pair.key, pair.value),
    );
  }

  void _handleAnswer(Color selectedColor) {
    if (selectedColor == game.displayedColor) {
      LaunchService.markOnboardingSeen().then((_) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.correct),
              content: Text(AppLocalizations.of(context)!.youCanContinue),
              actions: [
                TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(AppLocalizations.of(context)!.continueLabel),
                ),
              ],
            ),
          );
        }
      });
    } else {
      setState(() {
        _generateGame();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorName = getColorName(game.wordKey, localizations);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                          color: game.options[0],
                          isCorrect: game.options[0] == game.displayedColor,
                          onFinished: () => _handleAnswer(game.options[0]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ColorOptionButton(
                          color: game.options[1],
                          isCorrect: game.options[1] == game.displayedColor,
                          onFinished: () => _handleAnswer(game.options[1]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ColorOptionButton(
                          color: game.options[2],
                          isCorrect: game.options[2] == game.displayedColor,
                          onFinished: () => _handleAnswer(game.options[2]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ColorOptionButton(
                          color: game.options[3],
                          isCorrect: game.options[3] == game.displayedColor,
                          onFinished: () => _handleAnswer(game.options[3]),
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
  }
}

String getColorName(String key, AppLocalizations loc) {
  switch (key) {
    case 'red':
      return loc.red;
    case 'blue':
      return loc.blue;
    case 'green':
      return loc.green;
    case 'yellow':
      return loc.yellow;
    case 'orange':
      return loc.orange;
    case 'purple':
      return loc.purple;
    case 'pink':
      return loc.pink;
    case 'grey':
      return loc.grey;
    case 'brown':
      return loc.brown;
    case 'white':
      return loc.white;
    default:
      return key;
  }
}

// Nuevo widget extraído
class ColorOptionButton extends StatefulWidget {
  final Color color;
  final bool isCorrect;
  final VoidCallback onFinished;

  const ColorOptionButton({
    super.key,
    required this.color,
    required this.isCorrect,
    required this.onFinished,
  });

  @override
  State<ColorOptionButton> createState() => _ColorOptionButtonState();
}

class _ColorOptionButtonState extends State<ColorOptionButton> {
  Color? _overlay;
  bool _pressed = false;

  @override
  void didUpdateWidget(covariant ColorOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      setState(() {
        _pressed = false;
        _overlay = null;
      });
    }
  }

  void _handleTap() {
    if (_pressed) return;
    setState(() {
      _pressed = true;
      _overlay = widget.isCorrect
          ? Colors.green.withValues(alpha: 0.5)
          : Colors.red.withValues(alpha: 0.5);
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onFinished();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        children: [
          ElevatedButton(
            onPressed: _pressed ? null : _handleTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              minimumSize: const Size.fromHeight(80),
            ),
            child: const SizedBox.shrink(),
          ),
          if (_overlay != null)
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: _overlay,
                child: Center(
                  child: Text(
                    widget.isCorrect ? '✅' : '❌',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
