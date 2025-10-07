import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bulkmind/core/providers/base_game_provider.dart';
import 'package:bulkmind/core/utils/game_feedback_utils.dart';
import 'package:bulkmind/core/widgets/app_back_button.dart';
import 'package:bulkmind/core/widgets/retry_button.dart';
import 'package:bulkmind/features/intuition/domain/entities/color_game_data.dart';
import 'package:bulkmind/features/onboarding/domain/usecases/generate_color_game.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class IntuitionGameProvider extends BaseGameProvider {
  IntuitionGameProvider() : super(featureKey: 'intuition') {
    _initializeGame();
  }

  ColorGameData? _game;
  bool _showCorrectIconFeedback = false;
  bool _isDisposed = false;
  Timer? _feedbackTimer;

  ColorGameData? get game => _game;
  int get levelNumber => level;
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;

  void handleAnswer(Color selectedColor, BuildContext context) {
    if (isLoading || _game == null) {
      return;
    }

    if (selectedColor == _game!.displayedColor) {
      level += 1;
      _showCorrectFeedback();
      _generateLevelGame();
      return;
    }

    _onGameOver();
    _showGameOverDialog(context: context, isTimeout: false);
  }

  void onTimeOut(BuildContext context) {
    _onGameOver();
    _showGameOverDialog(context: context, isTimeout: true);
  }

  void _initializeGame() {
    level = 0;
    _showCorrectIconFeedback = false;
    gameEndedAt = null;
    gameStartedAt = DateTime.now();
    _generateLevelGame();
  }

  void _generateLevelGame() {
    final pair = generateColorWordPair();
    final Duration timeLimit = _calculateTimeLimitForLevel(level);
    maxTimeOut = timeLimit;

    _game = ColorGameData(
      wordKey: pair.key,
      displayedColor: pair.value,
      options: generateColorOptions(pair.key, pair.value),
      timeLimit: timeLimit,
    );

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _showGameOverDialog({
    required BuildContext context,
    required bool isTimeout,
  }) async {
    final int currentLevel = level;
    final localizations = AppLocalizations.of(context)!;

    final bool hasNewRecord = isNewRecord(
      level: currentLevel,
      elapsedMilliseconds: totalElapsedTime.inMilliseconds,
    );

    if (hasNewRecord) {
      await saveRecord(
        level: currentLevel,
        elapsedMilliseconds: totalElapsedTime.inMilliseconds,
      );
    }

    final feedback = buildGameOverFeedback(
      isTimeout: isTimeout,
      localizations: localizations,
      totalElapsedTime: totalElapsedTime,
      currentLevel: currentLevel,
      record: record,
      hasNewRecord: hasNewRecord,
    );

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(feedback.title),
        content: Text(feedback.message),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          AppBackButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              GoRouter.of(context).go('/');
            },
          ),
          RetryButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _restartGame();
            },
          ),
        ],
      ),
    );
  }

  void _showCorrectFeedback() {
    _feedbackTimer?.cancel();
    _showCorrectIconFeedback = true;
    if (!_isDisposed) {
      notifyListeners();
    }
    _feedbackTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isDisposed) {
        return;
      }
      _showCorrectIconFeedback = false;
      notifyListeners();
    });
  }

  void _restartGame() {
    _feedbackTimer?.cancel();
    _showCorrectIconFeedback = false;
    level = 0;
    gameEndedAt = null;
    gameStartedAt = DateTime.now();
    _generateLevelGame();
  }

  void _onGameOver() {
    gameEndedAt = DateTime.now();
    maxTimeOut = Duration.zero;
  }

  static Duration _calculateTimeLimitForLevel(int level) {
    if (level > 24) {
      return const Duration(milliseconds: 1500);
    }
    if (level > 17) {
      return const Duration(milliseconds: 1800);
    }
    if (level > 12) {
      return const Duration(milliseconds: 2000);
    }
    if (level > 7) {
      return const Duration(milliseconds: 2200);
    }
    if (level >= 6) {
      return const Duration(seconds: 2);
    }
    if (level >= 3) {
      return const Duration(seconds: 3);
    }
    return const Duration(seconds: 4);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _feedbackTimer?.cancel();
    super.dispose();
  }
}
