import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mind_builder/core/database/game_database.dart';
import 'package:mind_builder/features/memory/domain/usescases/generate_puzzle.dart';
import 'package:mind_builder/l10n/app_localizations.dart';

class MemoryProvider extends ChangeNotifier {
  int level = 0;
  Set<int> pressed = {};

  Map<String, int> currentRecord = {};

  final Stopwatch _stopwatchTotalTime = Stopwatch();

  Timer? _timerTotalTime;

  String _elapsedTotalTimeFormatted = '00:00.00';

  bool _showCorrectIconFeedback = false;

  int rows = 0;
  int columns = 0;

  late List<List<bool>> userPattern; // user pattern
  late List<List<bool>> initialPattern = []; // pattern to memorize

  DateTime? startTime;
  double maxTime = 0;

  final _db = GameDataBase();

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

  void reset() {
    level = 0;
    _stopTotalTimeTimer();
    _startTotalTimeTimer();
    _generatePuzzle();
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
          _showErrorDialog(
            context,
            isRecord,
            level - 1,
            _stopwatchTotalTime.elapsedMilliseconds,
          );
        }
        _stopTotalTimeTimer();
      });
    }
  }

  void _showErrorDialog(
    BuildContext context,
    bool isRecord,
    int level,
    int time,
  ) {
    final localizations = AppLocalizations.of(context)!;
    _saveData(level, time);

    String formattedTime = _formatDuration(_stopwatchTotalTime.elapsed);
    String contentText = isRecord
        ? '${localizations.newRecord}: ${localizations.level} $level,  ${localizations.time} $formattedTime'
        : '${localizations.level} $level, ${localizations.time} $formattedTime';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(localizations.incorrect),
        content: Text(contentText),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reset();
              notifyListeners();
            },
            child: Text(localizations.restart),
          ),
        ],
      ),
    );
  }

  Future<bool> _inNewRecord() async {
    return await _db.isNewRecord(
      featureKey: 'memory',
      level: level,
      time: _stopwatchTotalTime.elapsedMilliseconds,
    );
  }

  Future<void> _saveData(int level, int time) async {
    await _db.saveGameData(featureKey: 'memory', level: level, time: time);
  }

  void _startTotalTimeTimer() {
    _stopwatchTotalTime.start();
    _timerTotalTime?.cancel();
    _timerTotalTime = Timer.periodic(const Duration(milliseconds: 100), (_) {
      String newFormattedTime = _formatDuration(_stopwatchTotalTime.elapsed);
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = (duration.inMilliseconds.remainder(1000) / 10)
        .truncate()
        .toString()
        .padLeft(2, '0');
    return "$minutes:$seconds.$milliseconds";
  }

  Future<void> _loadCurrentRecord() async {
    final data = await _db.loadGameData(featureKey: 'memory');
    final maxLevel = data['maxLevel'] as int;
    final bestTime = data['bestTime'] as int;

    if (maxLevel > 0) {
      currentRecord = {'maxLevel': maxLevel, 'bestTime': bestTime};
    } else {
      currentRecord = {};
    }
    notifyListeners();
  }
}
