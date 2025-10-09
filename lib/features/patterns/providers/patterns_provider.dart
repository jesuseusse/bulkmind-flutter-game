import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bulkmind/core/providers/base_game_provider.dart';
import 'package:bulkmind/core/utils/game_feedback_utils.dart';
import 'package:bulkmind/core/widgets/app_back_button.dart';
import 'package:bulkmind/core/widgets/retry_button.dart';
import 'package:bulkmind/features/patterns/domain/usescases/generate_puzzle.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class PatternsProvider extends BaseGameProvider {
  PatternsProvider() : super(featureKey: 'patterns') {
    // Defer initialization to next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  int _rows = 0;
  int _columns = 0;
  bool _showPattern = true;
  bool _hasShownGameOverDialog = false;
  bool _isDisposed = false;

  DateTime? _levelStartedAt;

  List<List<bool>> _userPattern = <List<bool>>[];
  List<List<bool>> _gamePattern = <List<bool>>[];

  Timer? _showPatternTimer;

  int get rows => _rows;
  int get columns => _columns;
  bool get showPattern => _showPattern;
  bool get hasShownTimeoutDialog => _hasShownGameOverDialog;
  DateTime? get startTime => _levelStartedAt;
  DateTime? get totalTimeEnd => gameEndedAt;
  List<List<bool>> get userPattern => _userPattern;
  List<List<bool>> get gamePattern => _gamePattern;

  Future<void> handleCellTap(int row, int col, BuildContext context) async {
    if (_hasShownGameOverDialog || _gamePattern.isEmpty) {
      return;
    }
    _showPattern = false;
    _userPattern[row][col] = true;

    _notifySafely();

    if (_gamePattern[row][col]) {
      if (_allCellsMatch()) {
        final int nextLevel = level + 1;
        level = nextLevel;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isDisposed) {
            return;
          }
          _generateLevelGame(level: level);
          notifyListeners();
        });
      } else {
        notifyListeners();
      }
      return;
    }

    // in case of wrong selection

    _onGameOver();

    _hasShownGameOverDialog = true;

    _notifySafely();

    // Defer dialog to next frame to avoid building during build

    if (context.mounted) {
      _showGameOverDialog(context: context, isTimeout: false);
    }
  }

  void _initializeGame() {
    level = 0;
    gameStartedAt = DateTime.now();
    gameEndedAt = null;
    _hasShownGameOverDialog = false;
    _generateLevelGame(level: level);
    notifyListeners();
  }

  void _initializeUserPattern(int rows, int columns) {
    _userPattern = List.generate(
      rows,
      (_) => List.generate(columns, (_) => false),
    );
  }

  bool _allCellsMatch() {
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _columns; c++) {
        if (_gamePattern[r][c] != _userPattern[r][c]) {
          return false;
        }
      }
    }
    return true;
  }

  void _generateLevelGame({int level = 0}) {
    final List<List<bool>> previousPattern = _gamePattern;
    final LevelData levelData = generateLevel(level, previousPattern);

    _gamePattern = levelData.pattern;
    _initializeUserPattern(levelData.gridSize[0], levelData.gridSize[1]);
    _rows = levelData.gridSize[0];
    _columns = levelData.gridSize[1];
    _hasShownGameOverDialog = false;
    _levelStartedAt = DateTime.now();
    maxTimeOut = Duration(milliseconds: levelData.maxTimeMilliseconds);
    _showPatternDuration(maxTimeOut);
  }

  void _onGameOver() {
    gameEndedAt = DateTime.now();
    maxTimeOut = Duration.zero;
  }

  void onTimeOut(BuildContext context) {
    if (_hasShownGameOverDialog) {
      return;
    }
    _onGameOver();
    _hasShownGameOverDialog = true;
    if (context.mounted) {
      _showGameOverDialog(context: context, isTimeout: true);
    }
  }

  Future<void> _showGameOverDialog({
    required BuildContext context,
    required bool isTimeout,
  }) {
    final bool hasNewRecord = isNewRecord(
      level: level,
      elapsedMilliseconds: totalElapsedTime.inMilliseconds,
    );

    if (hasNewRecord) {
      saveRecord(
        level: level,
        elapsedMilliseconds: totalElapsedTime.inMilliseconds,
      );
    }

    final localizations = AppLocalizations.of(context)!;
    final feedback = buildGameOverFeedback(
      isTimeout: isTimeout,
      localizations: localizations,
      totalElapsedTime: totalElapsedTime,
      currentLevel: level,
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
              _initializeGame();
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showPatternDuration(Duration maxTime) {
    // 1. Cancel the previous timer if it exists and is active.
    // This is the key step to prevent multiple, simultaneous calls.
    _showPatternTimer?.cancel();

    final Duration duration = maxTime * 0.5;
    _showPattern = true;
    // You might want to call notifyListeners() here if _showPattern changing
    // to true needs to be reflected immediately in the UI.

    // 2. Create a new Timer instance.
    _showPatternTimer = Timer(duration, () {
      if (_isDisposed) {
        return;
      }

      // 3. Set the timer to null after it fires to clean up.
      _showPatternTimer = null;

      _showPattern = false;
      notifyListeners();
    });
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _showPatternTimer?.cancel();
    _isDisposed = true;
    super.dispose();
  }
}
