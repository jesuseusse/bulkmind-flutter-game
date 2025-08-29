import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bulkmind/features/intuition/domain/entities/color_game_data.dart';
import 'package:bulkmind/features/onboarding/domain/usecases/generate_color_game.dart';
import 'package:bulkmind/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntuitionGameProvider extends ChangeNotifier {
  ColorGameData? _game;
  int _levelNumber = 0;
  int _maxLevel = 0;
  double _bestTime = double.infinity;
  bool _isLoading = true;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _elapsedTimeFormatted = '00:00.00';

  ColorGameData? get game => _game;
  int get levelNumber => _levelNumber;
  int get maxLevel => _maxLevel;
  double get bestTime => _bestTime;
  bool get isLoading => _isLoading;
  String get elapsedTimeFormatted => _elapsedTimeFormatted;

  final StreamController<bool> _correctAnswerStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get correctAnswerStream => _correctAnswerStreamController.stream;

  // --- New: Flag to control icon visibility state ---
  bool _showCorrectIconFeedback = false;
  bool get showCorrectIconFeedback => _showCorrectIconFeedback;
  // --- End New ---

  IntuitionGameProvider() {
    _initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  Future<void> _initGame() async {
    await _loadGameData();
    _generateGame();
    _isLoading = false;
    notifyListeners();
    _startTimer();
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

  void _generateGame() {
    final pair = generateColorWordPair();
    _game = ColorGameData(
      wordKey: pair.key,
      displayedColor: pair.value,
      options: generateColorOptions(pair.key, pair.value),
    );
    notifyListeners();
  }

  void _startTimer() {
    _stopwatch.reset();
    _stopwatch.start();
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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
    String milliseconds = twoDigits(
      (duration.inMilliseconds.remainder(1000) / 10).truncate(),
    );
    return "$minutes:$seconds.$milliseconds";
  }

  void handleAnswer(Color selectedColor, BuildContext context) {
    if (_isLoading || _game == null) return;

    if (selectedColor == _game!.displayedColor) {
      // Correct Answer logic
      _levelNumber += 1;
      _generateGame(); // Generates new game, triggers rebuild of options

      // --- New: Show and then hide the icon ---
      _showCorrectIconFeedback = true;
      notifyListeners(); // Notify UI to show icon

      Future.delayed(const Duration(milliseconds: 500), () {
        // Display for 0.5 seconds
        _showCorrectIconFeedback = false;
        notifyListeners(); // Notify UI to hide icon
      });
      // --- End New ---
    } else {
      // Incorrect Answer logic (same as before)
      _stopTimer();

      bool isNewLevelRecord = _levelNumber > _maxLevel;
      bool isNewTimeRecord = false;

      double currentTimeTakenMillis = _stopwatch.elapsed.inMilliseconds
          .toDouble();

      if (isNewLevelRecord) {
        _maxLevel = _levelNumber;
        _bestTime = currentTimeTakenMillis;
        isNewTimeRecord = true;
      } else if (_levelNumber == _maxLevel) {
        if (currentTimeTakenMillis < _bestTime) {
          _bestTime = currentTimeTakenMillis;
          isNewTimeRecord = true;
        }
      }

      if (isNewLevelRecord || isNewTimeRecord) {
        _saveGameData(_maxLevel, _bestTime);
      }

      _showGameOverDialog(
        context,
        isNewLevelRecord,
        isNewTimeRecord,
        _levelNumber,
        _stopwatch.elapsed,
        _maxLevel,
        _bestTime,
      );

      // notifyListeners(); // Already called by _showGameOverDialog internally if it uses _levelNumber etc.
    }
  }

  void _showGameOverDialog(
    BuildContext context,
    bool isNewLevelRecord,
    bool isNewTimeRecord,
    int currentLevelReached,
    Duration currentTimeTaken,
    int globalMaxLevel,
    double globalBestTime,
  ) {
    final localizations = AppLocalizations.of(context)!;
    String recordMessage = '';

    recordMessage +=
        '${localizations.yourScore}: $currentLevelReached ${localizations.levels}\n';
    recordMessage +=
        '${localizations.timeTaken}: ${_formatDuration(currentTimeTaken)}\n\n';

    if (isNewLevelRecord) {
      recordMessage +=
          '🎉 ${localizations.newRecord}: $globalMaxLevel ${localizations.levels}\n';
      recordMessage +=
          '⏱️ ${localizations.newBestTime}: ${_formatDuration(Duration(milliseconds: globalBestTime.toInt()))}';
    } else {
      recordMessage +=
          '${localizations.maxLevel}: $globalMaxLevel ${localizations.levels}\n';
      if (globalBestTime != double.infinity) {
        recordMessage +=
            '⏱️ ${localizations.bestTime}: ${_formatDuration(Duration(milliseconds: globalBestTime.toInt()))}';
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
              _levelNumber = 0; // Reset level
              _generateGame(); // Generate new game
              _startTimer(); // Restart timer for new game
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
}
