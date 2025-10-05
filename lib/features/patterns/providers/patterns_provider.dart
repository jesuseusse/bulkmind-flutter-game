import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:bulkmind/core/database/game_database.dart';
import 'package:bulkmind/core/models/record.dart';
import 'package:bulkmind/core/utils/time_utils.dart';
import 'package:bulkmind/core/widgets/app_back_button.dart';
import 'package:bulkmind/core/widgets/retry_button.dart';
import 'package:bulkmind/features/patterns/domain/usescases/generate_puzzle.dart';
import 'package:bulkmind/l10n/app_localizations.dart';

class PatternsProvider extends ChangeNotifier {
  final GameDataBase _db = GameDataBase();

  int _level = 0;
  int _rows = 0;
  int _columns = 0;
  int _maxTimeMilliseconds = 0;
  bool _showCorrectIconFeedback = false;
  bool _hasShownTimeoutDialog = false;
  bool _isDisposed = false;

  DateTime? _startTime;
  DateTime? _totalTimeStart;
  DateTime? _totalTimeEnd;

  List<List<bool>> _userPattern = <List<bool>>[];
  List<List<bool>> _initialPattern = <List<bool>>[];

  Record _currentRecord = const Record(maxLevel: 0, bestTime: 0);

  PatternsProvider() {
    _generatePuzzle();
    _startTotalTimeTracking();
    _loadCurrentRecord();
  }

  int get level => _level;
  int get rows => _rows;
  int get columns => _columns;
  int get maxTimeMilliseconds => _maxTimeMilliseconds;
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;
  bool get hasShownTimeoutDialog => _hasShownTimeoutDialog;
  DateTime? get startTime => _startTime;
  DateTime? get totalTimeEnd => _totalTimeEnd;
  List<List<bool>> get userPattern => _userPattern;
  List<List<bool>> get initialPattern => _initialPattern;
  Record get currentRecord => _currentRecord;
  Duration get elapsedLevelTime {
    final DateTime? start = _startTime;
    if (start == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(start);
  }

  bool isInMemorizationPhase(Duration elapsed) {
    if (_startTime == null || _maxTimeMilliseconds <= 0) {
      return false;
    }
    final double memorizationWindowMs = _maxTimeMilliseconds * 0.5;
    return elapsed.inMilliseconds < memorizationWindowMs;
  }

  void handleCellTap(int row, int col, BuildContext context) {
    if (_hasShownTimeoutDialog) {
      return;
    }

    if (_initialPattern[row][col]) {
      _userPattern[row][col] = true;

      bool allMatch = true;
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _columns; c++) {
          if (_initialPattern[r][c] != _userPattern[r][c]) {
            allMatch = false;
            break;
          }
        }
        if (!allMatch) {
          break;
        }
      }

      if (allMatch) {
        _showCorrectIconFeedback = true;
        _notifySafely();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_isDisposed) return;
          _showCorrectIconFeedback = false;
          _notifySafely();
          _levelComplete();
        });
      } else {
        _notifySafely();
      }
    } else {
      final int time = _computeTotalElapsed().inMilliseconds;
      final bool isRecord = _inNewRecord(time);
      _stopTotalTimeTracking();
      if (context.mounted) {
        _hasShownTimeoutDialog = true;
        _notifySafely();
        _showGameOverDialog(context, isRecord, _level, time);
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
      _notifySafely();
      _showGameOverDialog(context, isRecord, _level, time, isTimeout: true);
    }
  }

  void _generatePuzzle() {
    final List<List<bool>> previousPattern = _initialPattern;
    final LevelData levelCreated = generateLevel(_level, previousPattern);
    _initialPattern = levelCreated.pattern;

    _initializeUserPattern(levelCreated.gridSize[0], levelCreated.gridSize[1]);
    _rows = levelCreated.gridSize[0];
    _columns = levelCreated.gridSize[1];
    _maxTimeMilliseconds = levelCreated.maxTimeMilliseconds;
    _startTime = DateTime.now();
    _hasShownTimeoutDialog = false;
    _notifySafely();
  }

  void _initializeUserPattern(int rows, int columns) {
    _userPattern = List.generate(
      rows,
      (_) => List.generate(columns, (_) => false),
    );
  }

  void _levelComplete() {
    _level++;
    if (_isDisposed) return;
    _generatePuzzle();
  }

  void _reset() {
    _level = 0;
    _stopTotalTimeTracking();
    if (_isDisposed) return;
    _generatePuzzle();
    _startTotalTimeTracking();
    _hasShownTimeoutDialog = false;
    _notifySafely();
  }

  void _showGameOverDialog(
    BuildContext context,
    bool isRecord,
    int level,
    int time, {
    bool isTimeout = false,
  }) {
    final localizations = AppLocalizations.of(context)!;
    if (isRecord) {
      _saveData(level, time);
    }
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
          '${localizations.maxLevel}: ${_currentRecord.maxLevel} ${localizations.levels}\n';
      if (_currentRecord.bestTime > 0) {
        recordMessage +=
            '⏱️ ${localizations.bestTime}: ${formatDuration(Duration(milliseconds: _currentRecord.bestTime))}';
      }
    }

    final String dialogTitle = isTimeout
        ? '⏰ ${localizations.timeOut}'
        : localizations.youAreALooser;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(recordMessage),
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
              _reset();
            },
          ),
        ],
      ),
    );
  }

  void _startTotalTimeTracking() {
    _totalTimeStart = DateTime.now();
    _totalTimeEnd = null;
    _notifySafely();
  }

  void _stopTotalTimeTracking() {
    if (_totalTimeStart == null) {
      return;
    }
    if (_totalTimeEnd == null) {
      _totalTimeEnd = DateTime.now();
      _notifySafely();
    }
  }

  Duration _computeTotalElapsed() {
    if (_totalTimeStart == null) {
      return Duration.zero;
    }
    final DateTime endReference = _totalTimeEnd ?? DateTime.now();
    return endReference.difference(_totalTimeStart!);
  }

  bool _inNewRecord(int elapsedTime) {
    if (_level > _currentRecord.maxLevel) {
      return true;
    }
    if (_level == _currentRecord.maxLevel &&
        (_currentRecord.bestTime == 0 ||
            elapsedTime < _currentRecord.bestTime)) {
      return true;
    }
    return false;
  }

  Future<void> _saveData(int level, int time) async {
    await _db.saveGameData(featureKey: 'patterns', level: level, time: time);
    if (_isDisposed) {
      return;
    }
    _currentRecord = Record(maxLevel: level, bestTime: time);
    _notifySafely();
  }

  Future<void> _loadCurrentRecord() async {
    final data = await _db.loadGameData(featureKey: 'patterns');
    if (_isDisposed) {
      return;
    }
    final int maxLevel = data['maxLevel'] as int? ?? 0;
    final int bestTime = data['bestTime'] as int? ?? 0;
    _currentRecord = Record(maxLevel: maxLevel, bestTime: bestTime);
    _notifySafely();
  }

  void _notifySafely() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTotalTimeTracking();
    super.dispose();
  }
}
