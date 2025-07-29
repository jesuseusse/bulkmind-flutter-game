import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mind_builder/features/memory/domain/usescases/generate_puzzle.dart';

class MemoryProvider extends ChangeNotifier {
  int level = 0;

  Set<int> pressed = {};

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

  double get initialPatternProgress {
    if (startTime == null) return 0.0;
    final elapsed = DateTime.now().difference(startTime!).inMilliseconds;
    final progress = elapsed / 3000;
    return progress.clamp(0.0, 1.0);
  }

  String get elapsedTotalTimeFormatted => _elapsedTotalTimeFormatted;

  bool get showCorrectIconFeedback => _showCorrectIconFeedback;

  MemoryProvider() {
    _generatePuzzle();
    _startTotalTimeTimer();
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
      // Incorrect tap: reset game and show error dialog
      _showErrorDialog(context);
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('❌ Incorrecto'),
        content: Text('Volviste al nivel 0'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              reset();
              notifyListeners();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
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
}
