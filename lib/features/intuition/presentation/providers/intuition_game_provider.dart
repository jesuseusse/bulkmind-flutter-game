import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bulkmind/core/utils/time_utils.dart';
import 'package:bulkmind/features/intuition/domain/entities/color_game_data.dart';
import 'package:bulkmind/features/onboarding/domain/usecases/generate_color_game.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class IntuitionGameProvider extends ChangeNotifier {
  final StreamController<bool> _correctAnswerStreamController =
      StreamController<bool>.broadcast();

  ColorGameData? _game;
  int _levelNumber = 0;
  int _maxLevel = 0;
  double _bestTime = double.infinity;
  bool _isLoading = true;
  bool _showCorrectIconFeedback = false;
  DateTime _startTimeGame = DateTime.now();
  bool _isDisposed = false;

  IntuitionGameProvider() {
    unawaited(_initGame());
  }

  ColorGameData? get game => _game;
  int get levelNumber => _levelNumber;
  int get maxLevel => _maxLevel;
  double get bestTime => _bestTime;
  bool get isLoading => _isLoading;
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;
  DateTime get startTimeGame => _startTimeGame;
  Stream<bool> get correctAnswerStream => _correctAnswerStreamController.stream;

  void handleAnswer(Color selectedColor, BuildContext context) {
    if (_isLoading || _game == null) return;

    if (selectedColor == _game!.displayedColor) {
      _levelNumber += 1;
      _generateLevelGame(); // Generates new game, triggers rebuild of options

      _showCorrectIconFeedback = true;
      if (!_isDisposed) {
        notifyListeners();
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isDisposed) return;
        _showCorrectIconFeedback = false;
        notifyListeners(); // Notify UI to hide icon
      });
    } else {
      bool isNewLevelRecord = _levelNumber > _maxLevel;
      bool isNewTimeRecord = false;

      if (isNewLevelRecord) {
        _maxLevel = _levelNumber;
        isNewTimeRecord = true;
      } else if (_levelNumber == _maxLevel) {}

      if (isNewLevelRecord || isNewTimeRecord) {
        _saveGameData(_maxLevel, _bestTime);
      }

      // calculate time taken
      final timeTaken = DateTime.now().difference(_startTimeGame);

      // wrong answer then show dialog
      _showGameOverDialog(
        context,
        isNewLevelRecord,
        isNewTimeRecord,
        _levelNumber,
        timeTaken,
        _maxLevel,
        _bestTime,
      );
    }
  }

  void showGameOverTimeOut(BuildContext context) {
    bool isNewLevelRecord = _levelNumber > _maxLevel;
    bool isNewTimeRecord = false;

    if (isNewLevelRecord) {
      _maxLevel = _levelNumber;
      isNewTimeRecord = true;
    } else if (_levelNumber == _maxLevel) {}

    if (isNewLevelRecord || isNewTimeRecord) {
      _saveGameData(_maxLevel, _bestTime);
    }

    // calculate time taken
    final timeTaken = DateTime.now().difference(_startTimeGame);

    // timeout then show dialog
    _showGameOverDialog(
      context,
      isNewLevelRecord,
      isNewTimeRecord,
      _levelNumber,
      timeTaken,
      _maxLevel,
      _bestTime,
      isTimeout: true,
    );
  }

  void _showGameOverDialog(
    BuildContext context,
    bool isNewLevelRecord,
    bool isNewTimeRecord,
    int currentLevelReached,
    Duration currentTimeTaken,
    int globalMaxLevel,
    double globalBestTime, {
    bool isTimeout = false,
  }) {
    final localizations = AppLocalizations.of(context)!;
    String recordMessage = '';

    recordMessage +=
        '${localizations.yourScore}: $currentLevelReached ${localizations.levels}\n';
    recordMessage +=
        '${localizations.timeTaken}: ${formatDuration(currentTimeTaken)}\n\n';

    if (isNewLevelRecord) {
      recordMessage +=
          '🎉 ${localizations.newRecord}: $globalMaxLevel ${localizations.levels}\n';
      recordMessage +=
          '⏱️ ${localizations.newBestTime}: ${formatDuration(Duration(milliseconds: globalBestTime.toInt()))}';
    } else {
      recordMessage +=
          '${localizations.maxLevel}: $globalMaxLevel ${localizations.levels}\n';
      if (globalBestTime != double.infinity) {
        recordMessage +=
            '⏱️ ${localizations.bestTime}: ${formatDuration(Duration(milliseconds: globalBestTime.toInt()))}';
      }
    }

    final dialogTitle = isTimeout
        ? '⏰ ${localizations.timeOut}'
        : localizations.youAreALooser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(recordMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _levelNumber = 0; // Reset level
              _startTimeGame = DateTime.now();
              _generateLevelGame(); // Generate new game
              notifyListeners(); // Ensure UI reflects reset level and new game
            },
            child: Text(localizations.restart),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              GoRouter.of(context).go('/');
            },
            child: Text(localizations.back),
          ),
        ],
      ),
    );
  }

  Future<void> _initGame() async {
    await _loadGameData();
    if (_isDisposed) return;
    _generateLevelGame();
    _startTimeGame = DateTime.now();
    _isLoading = false;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _maxLevel = prefs.getInt('intuition-maxLevel') ?? 0;
      _bestTime = prefs.getDouble('intuition-bestTime') ?? double.infinity;
    } catch (e) {
      debugPrint('Error loading game data: $e');
      _maxLevel = 0;
      _bestTime = double.infinity;
    }
  }

  Future<void> _saveGameData(int level, double time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('intuition-maxLevel', level);
      await prefs.setDouble('intuition-bestTime', time);
    } catch (e) {
      debugPrint('Error saving game data: $e');
    }
  }

  void _generateLevelGame() {
    final pair = generateColorWordPair();
    final Duration timeLimit = _calculateTimeLimitForLevel(_levelNumber);
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

  Duration _calculateTimeLimitForLevel(int level) {
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
    _correctAnswerStreamController.close();
    super.dispose();
  }
}
