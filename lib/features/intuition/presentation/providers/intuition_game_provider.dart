import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_builder/l10n/app_localizations.dart';
import 'package:mind_builder/features/onboarding/domain/usecases/generate_color_game.dart'; // Assuming this is correct
import 'package:shared_preferences/shared_preferences.dart';

class IntuitionGameProvider extends ChangeNotifier {
  ColorGameData? _game;
  int _levelNumber = 0;
  int _maxLevel = 0;
  bool _isLoading = true; // To indicate loading initial data

  ColorGameData? get game => _game;
  int get levelNumber => _levelNumber;
  int get maxLevel => _maxLevel;
  bool get isLoading => _isLoading;

  IntuitionGameProvider() {
    _initGame();
  }

  Future<void> _initGame() async {
    await _loadMaxLevel();
    _generateGame();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadMaxLevel() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _maxLevel = prefs.getInt('intuition-maxLevel') ?? 0;
    } catch (e) {
      // Log the error or show a user-friendly message
      debugPrint('Error loading max level: $e');
      _maxLevel = 0; // Default to 0 on error
    }
  }

  Future<void> _saveMaxLevel(int level) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('intuition-maxLevel', level);
    } catch (e) {
      // Log the error or show a user-friendly message
      debugPrint('Error saving max level: $e');
    }
  }

  void _generateGame() {
    final pair = generateColorWordPair();
    _game = ColorGameData(
      wordKey: pair.key,
      displayedColor: pair.value,
      options: generateColorOptions(pair.key, pair.value),
    );
    notifyListeners(); // Notify listeners that the game data has changed
  }

  void handleAnswer(Color selectedColor, BuildContext context) {
    if (_game == null) return;

    if (selectedColor == _game!.displayedColor) {
      _levelNumber += 1;
      _generateGame(); // Generates new game and notifies listeners
    } else {
      bool isNewRecord = _levelNumber > _maxLevel;
      if (isNewRecord) {
        _maxLevel = _levelNumber;
        _saveMaxLevel(_maxLevel);
      }
      _showGameOverDialog(isNewRecord, context);
    }
  }

  void _showGameOverDialog(bool isNewRecord, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.youAreALooser),
        content: Text(
          isNewRecord
              ? '🎉 ${localizations.newRecord}: $_maxLevel'
              : '${localizations.maxLevel}: $_maxLevel',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _levelNumber = 0;
              _generateGame(); // Resets level and generates new game
              notifyListeners();
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
