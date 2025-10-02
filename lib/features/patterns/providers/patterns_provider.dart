import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bulkmind/core/database/game_database.dart';
import 'package:bulkmind/core/models/record.dart';
import 'package:bulkmind/core/utils/time_utils.dart';
import 'package:bulkmind/features/patterns/domain/usescases/generate_puzzle.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class PatternsProvider extends ChangeNotifier {
  // Level settings
  int level = 0;
  bool _showCorrectIconFeedback = false;
  int rows = 0;
  int columns = 0;
  late List<List<bool>> userPattern; // user pattern
  late List<List<bool>> initialPattern = []; // pattern to memorize

  DateTime? startTime;
  double maxTime = 0;
  bool _hasShownTimeoutDialog = false;

  // DB records
  final _db = GameDataBase();
  Record currentRecord = const Record(maxLevel: 0, bestTime: 0);

  // Total time tracking
  DateTime? _totalTimeStart;
  DateTime? _totalTimeEnd;

  String get elapsedTotalTimeFormatted =>
      formatDuration(_computeTotalElapsed());
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;
  bool get hasShownTimeoutDialog => _hasShownTimeoutDialog;
  Duration get elapsedLevelTime {
    final start = startTime;
    if (start == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(start);
  }

  double levelRemainingTimeFraction({Duration? elapsed}) {
    if (startTime == null || maxTime <= 0) {
      return 1;
    }
    final Duration effectiveElapsed = elapsed ?? elapsedLevelTime;
    final double totalMilliseconds = maxTime * 1000;
    if (totalMilliseconds <= 0) {
      return 1;
    }
    return 1 - (effectiveElapsed.inMilliseconds / totalMilliseconds);
  }

  bool isInMemorizationPhase(Duration elapsed) {
    if (startTime == null || maxTime <= 0) {
      return false;
    }
    final double memorizationWindowMs = maxTime * 1000 * 0.5;
    return elapsed.inMilliseconds < memorizationWindowMs;
  }

  PatternsProvider() {
    _generatePuzzle();
    _startTotalTimeTracking();
    _loadCurrentRecord();
  }

  @override
  void dispose() {
    _stopTotalTimeTracking();
    super.dispose();
  }

  void _generatePuzzle() {
    LevelData levelCreated = generateLevel(level, initialPattern);
    initialPattern = levelCreated.pattern;

    _initializeUserPattern(levelCreated.gridSize[0], levelCreated.gridSize[1]);
    rows = levelCreated.gridSize[0];
    columns = levelCreated.gridSize[1];
    maxTime = levelCreated.maxTime;
    startTime = DateTime.now();
    _hasShownTimeoutDialog = false;
    notifyListeners();
  }

  void _initializeUserPattern(rows, columns) {
    userPattern = List.generate(
      rows,
      (_) => List.generate(columns, (_) => false),
    );
  }

  void _levelComplete() {
    level++;
    _generatePuzzle();
  }

  void _reset() {
    level = 0;
    _stopTotalTimeTracking();
    _generatePuzzle();
    _startTotalTimeTracking();
    _hasShownTimeoutDialog = false;
    notifyListeners();
  }

  void handleCellTap(int row, int col, BuildContext context) {
    if (_hasShownTimeoutDialog) {
      return;
    }
    // Check if the tapped cell matches the initial pattern
    if (initialPattern[row][col]) {
      // Correct tap: update userPattern to reflect the selection
      userPattern[row][col] = true;

      // Check if userPattern now fully matches the initialPattern
      bool allMatch = true;
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < columns; c++) {
          if (initialPattern[r][c] != userPattern[r][c]) {
            allMatch = false;
            break;
          }
        }
        if (!allMatch) break;
      }

      // If all cells match, show success feedback and go to next level
      if (allMatch) {
        _showCorrectIconFeedback = true;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCorrectIconFeedback = false;
          notifyListeners();
          _levelComplete();
        });
      } else {
        notifyListeners();
      }
    } else {
      final int time = _computeTotalElapsed().inMilliseconds;
      bool isRecord = _inNewRecord(time);
      _stopTotalTimeTracking();
      if (context.mounted) {
        _hasShownTimeoutDialog = true;
        _showGameOverDialog(context, isRecord, level, time);
      }
    }
  }

  void showGameOverDialog(BuildContext context) {
    if (_hasShownTimeoutDialog) {
      return;
    }
    final int time = _computeTotalElapsed().inMilliseconds;
    final bool isRecord = _inNewRecord(time);
    _stopTotalTimeTracking();
    if (context.mounted) {
      _hasShownTimeoutDialog = true;
      _showGameOverDialog(context, isRecord, level, time, isTimeout: true);
    }
  }

  void _showGameOverDialog(
    BuildContext context,
    bool isRecord,
    int level,
    int time, {
    bool isTimeout = false,
  }) {
    final localizations = AppLocalizations.of(context)!;
    if (isRecord) _saveData(level, time);
    String recordMessage = '';

    recordMessage +=
        '${localizations.yourScore}: $level ${localizations.levels}\n';
    recordMessage +=
        '${localizations.timeTaken}: ${formatDuration(Duration(milliseconds: time))}\n\n';

    if (isRecord) {
      recordMessage +=
          '🎉 ${localizations.newRecord}: $level ${localizations.levels}\n';
      recordMessage +=
          '⏱️ ${localizations.newBestTime}: ${formatDuration(Duration(milliseconds: time))}';
    } else {
      recordMessage +=
          '${localizations.maxLevel}: ${currentRecord.maxLevel} ${localizations.levels}\n';
      if (currentRecord.bestTime != double.infinity) {
        recordMessage +=
            '⏱️ ${localizations.bestTime}: ${formatDuration(Duration(milliseconds: currentRecord.bestTime))}';
      }
    }

    final dialogTitle = isTimeout
        ? '⏰ ${localizations.timeTaken}'
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
              GoRouter.of(context).go('/');
            },
            child: Text(localizations.back),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _reset();
            },
            child: Text(localizations.restart),
          ),
        ],
      ),
    );
  }

  void _startTotalTimeTracking() {
    _totalTimeStart = DateTime.now();
    _totalTimeEnd = null;
    notifyListeners();
  }

  void _stopTotalTimeTracking() {
    if (_totalTimeStart == null) {
      return;
    }
    if (_totalTimeEnd == null) {
      _totalTimeEnd = DateTime.now();
      notifyListeners();
    }
  }

  Duration _computeTotalElapsed() {
    if (_totalTimeStart == null) {
      return Duration.zero;
    }
    final endReference = _totalTimeEnd ?? DateTime.now();
    return endReference.difference(_totalTimeStart!);
  }

  bool _inNewRecord(int elapsedTime) {
    if (level > currentRecord.maxLevel) {
      return true;
    }

    if (level == currentRecord.maxLevel &&
        elapsedTime < currentRecord.bestTime) {
      return true;
    }

    return false;
  }

  Future<void> _saveData(int level, int time) async {
    await _db.saveGameData(featureKey: 'patterns', level: level, time: time);
    currentRecord = Record(maxLevel: level, bestTime: time);
    notifyListeners();
  }

  Future<void> _loadCurrentRecord() async {
    final data = await _db.loadGameData(featureKey: 'patterns');
    final maxLevel = data['maxLevel'] as int;
    final bestTime = data['bestTime'] as int;

    if (maxLevel > 0) {
      currentRecord = Record(maxLevel: maxLevel, bestTime: bestTime);
    } else {
      currentRecord = const Record(maxLevel: 0, bestTime: 0);
    }
    notifyListeners();
  }
}
