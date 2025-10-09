import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bulkmind/core/providers/base_game_provider.dart';
import 'package:bulkmind/core/utils/game_feedback_utils.dart';
import 'package:bulkmind/core/widgets/app_back_button.dart';
import 'package:bulkmind/core/widgets/retry_button.dart';
import 'package:bulkmind/features/logic/presentation/domain/usecases/generate_logic_puzzle.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class LogicProvider extends BaseGameProvider {
  String question = '';
  List<int> options = [];
  List<int> _solution = [];

  final Set<int> _pressedOptions = <int>{};

  LogicProvider() : super(featureKey: 'logic') {
    _initGame();
  }
  bool isOptionPressed(int value) => _pressedOptions.contains(value);

  void _initGame() {
    gameStartedAt = DateTime.now();
    gameEndedAt = null;
    level = 0;
    _pressedOptions.clear();
    _generateLevelGame();
  }

  void _onGameOver() {
    // should stop game time and set maxTimeOut to zero
    gameEndedAt = DateTime.now();
    maxTimeOut = Duration.zero;
  }

  void handleAnswer(int value, BuildContext context) {
    if (options.isEmpty) {
      return;
    }
    _pressedOptions.add(value);
    final int selectedIndex = _pressedOptions.length - 1;

    if (value != _solution[selectedIndex]) {
      _handleIncorrectSelection(context);
      return;
    }

    if (_pressedOptions.length == _solution.length) {
      _handleCorrectSelection();
      return;
    }
    notifyListeners();
  }

  void _handleCorrectSelection() {
    level += 1;
    _pressedOptions.clear();
    _generateLevelGame();
  }

  void _handleIncorrectSelection(BuildContext context) {
    _onGameOver();
    _showGameOverDialog(context: context, isTimeout: false);
  }

  Future<void> _showGameOverDialog({
    required BuildContext context,
    required bool isTimeout,
  }) {
    final currentLevel = level;
    final localizations = AppLocalizations.of(context)!;
    final bool hasNewRecord = isNewRecord(
      level: level,
      elapsedMilliseconds: totalElapsedTime.inMilliseconds,
    );

    if (hasNewRecord) {
      saveRecord(
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

    return showDialog<void>(
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
              _initGame();
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _generateLevelGame() async {
    final Map<String, dynamic> rawPuzzle = generateLogicPuzzle();
    question = rawPuzzle['question'] as String;
    options = List<int>.from(rawPuzzle['options'] as List<int>);
    _solution = List<int>.from(rawPuzzle['solution'] as List<int>);
    maxTimeOut = _calculateTimeLimitForLevel(level);

    notifyListeners();
  }

  Future<void> onTimeOut(BuildContext context) async {
    _onGameOver();
    _showGameOverDialog(context: context, isTimeout: true);
  }

  static Duration _calculateTimeLimitForLevel(int level) {
    if (level > 36) {
      return const Duration(milliseconds: 1800);
    }
    if (level > 30) {
      return const Duration(milliseconds: 2000);
    }
    if (level > 24) {
      return const Duration(milliseconds: 2200);
    }
    if (level > 17) {
      return const Duration(milliseconds: 2500);
    }
    if (level > 12) {
      return const Duration(milliseconds: 2800);
    }
    if (level > 7) {
      return const Duration(seconds: 3);
    }
    if (level >= 6) {
      return const Duration(seconds: 4);
    }
    if (level >= 3) {
      return const Duration(seconds: 6);
    }
    return const Duration(seconds: 10);
  }
}
