import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_builder/core/database/game_database.dart';
import 'package:mind_builder/core/models/record.dart';
import 'package:mind_builder/core/utils/time_utils.dart';
import 'package:mind_builder/features/memory/domain/usescases/generate_puzzle.dart';
import 'package:mind_builder/l10n/app_localizations.dart';

class MemoryProvider extends ChangeNotifier {
  // Level settings
  int level = 0;
  bool _showCorrectIconFeedback = false;
  int rows = 0;
  int columns = 0;
  late List<List<bool>> userPattern; // user pattern
  late List<List<bool>> initialPattern = []; // pattern to memorize

  DateTime? startTime;
  double maxTime = 0;

  // DB records
  final _db = GameDataBase();
  Record currentRecord = const Record(maxLevel: 0, bestTime: 0);

  // Total timers
  final Stopwatch _stopwatchTotalTime = Stopwatch();
  Timer? _timerTotalTime;
  String _elapsedTotalTimeFormatted = '00:00.00';

  String get elapsedTotalTimeFormatted => _elapsedTotalTimeFormatted;
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;

  MemoryProvider() {
    _generatePuzzle();
    _startTotalTimeTimer();
    _loadCurrentRecord();
  }

  @override
  void dispose() {
    _stopTotalTimeTimer();
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
    _stopTotalTimeTimer();
    _startTotalTimeTimer();
    _generatePuzzle();
    notifyListeners();
  }

  void handleCellTap(int row, int col, BuildContext context) {
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
      _stopwatchTotalTime.stop();
      _inNewRecord().then((isRecord) {
        if (context.mounted) {
          _showGameOverDialog(
            context,
            isRecord,
            level,
            _stopwatchTotalTime.elapsedMilliseconds,
          );
        }
        _stopTotalTimeTimer();
      });
    }
  }

  void _showGameOverDialog(
    BuildContext context,
    bool isRecord,
    int level,
    int time,
  ) {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.youAreALooser),
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

  void _startTotalTimeTimer() {
    _stopwatchTotalTime.start();
    _timerTotalTime?.cancel();
    _timerTotalTime = Timer.periodic(const Duration(milliseconds: 100), (_) {
      String newFormattedTime = formatDuration(_stopwatchTotalTime.elapsed);
      if (_elapsedTotalTimeFormatted != newFormattedTime) {
        _elapsedTotalTimeFormatted = newFormattedTime;
        notifyListeners();
      }
    });
  }

  void _stopTotalTimeTimer() {
    _stopwatchTotalTime.stop();
    _stopwatchTotalTime.reset();
    _timerTotalTime?.cancel();
  }

  // db handlers
  Future<bool> _inNewRecord() async {
    return await _db.isNewRecord(
      featureKey: 'memory',
      level: level,
      time: _stopwatchTotalTime.elapsedMilliseconds,
    );
  }

  Future<void> _saveData(int level, int time) async {
    await _db.saveGameData(featureKey: 'memory', level: level, time: time);
    currentRecord = Record(maxLevel: level, bestTime: time);
    notifyListeners();
  }

  Future<void> _loadCurrentRecord() async {
    final data = await _db.loadGameData(featureKey: 'memory');
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
