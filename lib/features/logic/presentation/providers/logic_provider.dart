import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:bulkmind/core/widgets/app_back_button.dart';
import 'package:bulkmind/core/widgets/retry_button.dart';
import 'package:bulkmind/features/logic/presentation/domain/usecases/generate_logic_puzzle.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class LogicProvider extends ChangeNotifier {
  LogicProvider() {
    _generatePuzzle();
  }

  int _level = 0;
  String _comparisonSymbol = '<';
  List<int> _options = const <int>[];
  List<int> _solution = const <int>[];
  final Set<int> _pressedOptions = <int>{};

  DateTime? _startTime;
  String _elapsedTimeFormatted = '00:00.00';
  bool _showCorrectIconFeedback = false;
  bool _isDisposed = false;
  bool _hasActiveDialog = false;
  Duration _timeLimit = const Duration(seconds: 4);
  int _timerSeed = 0;

  int get level => _level;
  String get comparisonSymbol => _comparisonSymbol;
  UnmodifiableListView<int> get options => UnmodifiableListView(_options);
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;
  String get elapsedTimeFormatted => _elapsedTimeFormatted;
  Duration get timeLimit => _timeLimit;
  int get timerSeed => _timerSeed;

  bool isOptionPressed(int value) => _pressedOptions.contains(value);

  void selectOption(int value, BuildContext context) {
    if (_isDisposed || _options.isEmpty) {
      return;
    }

    _updateElapsedTime();
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

    _notifySafely();
  }

  void resetGame() {
    _level = 0;
    _generatePuzzle();
  }

  void reset() => resetGame();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _generatePuzzle() {
    if (_isDisposed) {
      return;
    }
    final Map<String, dynamic> rawPuzzle = generateLogicPuzzle();
    _comparisonSymbol = rawPuzzle['question'] as String? ?? '<';
    _options = List<int>.from(rawPuzzle['options'] as List<int>);
    _solution = List<int>.from(rawPuzzle['solution'] as List<int>);
    _pressedOptions.clear();
    _timeLimit = _calculateTimeLimitForLevel(_level);
    _startTime = DateTime.now();
    _elapsedTimeFormatted = _formatDuration(Duration.zero);
    _hasActiveDialog = false;
    _timerSeed += 1;
    _notifySafely();
  }

  void _handleCorrectSelection() {
    if (_isDisposed) {
      return;
    }
    _updateElapsedTime();
    _showCorrectIconFeedback = true;
    _notifySafely();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_isDisposed) return;
      _showCorrectIconFeedback = false;
      _notifySafely();
    });
    _level++;
    _generatePuzzle();
  }

  void _handleIncorrectSelection(BuildContext context) {
    _updateElapsedTime();
    _level = 0;
    _generatePuzzle();
    _showErrorDialog(context);
  }

  void _showErrorDialog(BuildContext context) {
    if (_hasActiveDialog) {
      return;
    }
    _hasActiveDialog = true;
    final localizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('❌ ${localizations.incorrect}'),
        content: Text('${localizations.level}: $_level'),
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
              if (_isDisposed) return;
              _startTime = DateTime.now();
              _elapsedTimeFormatted = _formatDuration(Duration.zero);
              _hasActiveDialog = false;
              _notifySafely();
            },
          ),
        ],
      ),
    );
  }

  void _updateElapsedTime() {
    final DateTime? start = _startTime;
    if (start == null) {
      _elapsedTimeFormatted = _formatDuration(Duration.zero);
      return;
    }
    final Duration elapsed = DateTime.now().difference(start);
    _elapsedTimeFormatted = _formatDuration(elapsed);
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final String minutes = twoDigits(duration.inMinutes.remainder(60));
    final String seconds = twoDigits(duration.inSeconds.remainder(60));
    final String centiseconds = (duration.inMilliseconds.remainder(1000) / 10)
        .truncate()
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds.$centiseconds';
  }

  void handleTimeout(BuildContext context) {
    if (_isDisposed || _hasActiveDialog) {
      return;
    }

    _updateElapsedTime();
    final int failedLevel = _level;
    _level = 0;
    _pressedOptions.clear();
    _hasActiveDialog = true;

    final localizations = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('⏰ ${localizations.timeOut}'),
        content: Text('${localizations.level}: $failedLevel'),
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
              if (_isDisposed) {
                return;
              }
              _generatePuzzle();
            },
          ),
        ],
      ),
    );
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
}
