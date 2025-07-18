import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mind_builder/features/logic/presentation/domain/usecases/generate_logic_puzzle.dart';

class LogicProvider extends ChangeNotifier {
  int level = 0;
  late Map<String, dynamic> puzzle;

  Set<int> pressed = {};

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTimeFormatted = '00:00.00';
  bool _showCorrectIconFeedback = false;

  String get elapsedTimeFormatted => _elapsedTimeFormatted;
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;

  LogicProvider() {
    _generatePuzzle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _generatePuzzle() {
    puzzle = generateLogicPuzzle();
    _stopTimer();
    _startTimer();
    notifyListeners();
  }

  void _levelComplete() {
    level++;
    _generatePuzzle();
  }

  void reset() {
    level = 1;
    _generatePuzzle();
  }

  void selectOption(int value, BuildContext context) {
    pressed.add(value);

    final solution = puzzle['solution'] as List<int>;
    final selectedIndex = pressed.length - 1;

    if (value != solution[selectedIndex]) {
      // Incorrecto: resetear nivel
      level = 0;
      pressed.clear();
      _generatePuzzle();
      notifyListeners();
      _showErrorDialog(context);
      return;
    }

    if (pressed.length == solution.length) {
      // Correcto: subir nivel
      _showCorrectIconFeedback = true;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () {
        _showCorrectIconFeedback = false;
        notifyListeners();
      });
      _levelComplete();
      pressed.clear();
    }

    notifyListeners();
  }

  void _showErrorDialog(BuildContext context) {
    _stopTimer();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('❌ Incorrecto'),
        content: Text('Volviste al nivel $level'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startTimer();
              notifyListeners();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _stopwatch.reset();
    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      String newFormattedTime = _formatDuration(_stopwatch.elapsed);
      if (_elapsedTimeFormatted != newFormattedTime) {
        _elapsedTimeFormatted = newFormattedTime;
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
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
