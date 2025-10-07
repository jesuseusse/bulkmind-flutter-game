import 'dart:async';
import 'package:flutter/foundation.dart';

// Asegúrate de que las rutas de estos archivos sean correctas en tu proyecto
import 'package:bulkmind/core/database/game_database.dart';
import 'package:bulkmind/core/models/record.dart';
import 'package:flutter/material.dart';

/// Clase base abstracta para todos los proveedores de juegos.
/// Contiene la lógica de timing, persistencia y la estructura básica de nivel.
abstract class BaseGameProvider extends ChangeNotifier {
  final String featureKey;
  final GameDataBase _db = GameDataBase();

  // ----------------------------------------------------------------------
  // ⚙️ ESTADO CENTRAL (Accesible a Clases Hijas)
  // ----------------------------------------------------------------------

  /// Nivel actual del juego.
  int level = 0;
  String titleDialog = '';
  String contentDialog = '';

  /// Duración máxima permitida para completar un nivel (usado en onTimeOut).
  Duration maxTimeOut = Duration.zero;

  // --- Estado Interno (Privado a esta librería) ---
  Record _record = const Record(maxLevel: 0, bestTime: 0);
  DateTime? _gameStartedAt;
  DateTime? _gameEndedAt;

  bool _isLoading = false;

  // ----------------------------------------------------------------------
  // CONSTRUCTOR & INICIALIZACIÓN
  // ----------------------------------------------------------------------

  BaseGameProvider({required this.featureKey}) {
    _init(); // Inicia la carga del registro al crearse
  }

  /// Carga el registro guardado de la base de datos.
  Future<void> _init() async {
    _isLoading = true;
    // Se usa el método público 'getRecord'
    _record = await getRecord();
    _isLoading = false;
    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // GETTERS PÚBLICOS
  // ----------------------------------------------------------------------

  Record get record => _record;
  bool get isLoading => _isLoading;

  /// Retorna el tiempo total transcurrido, ya sea actual o finalizado.
  Duration get totalElapsedTime => _getTotalTime();

  DateTime? get gameStartedAt => _gameStartedAt;

  set gameStartedAt(DateTime? value) {
    _gameStartedAt = value;
    notifyListeners();
  }

  DateTime? get gameEndedAt => _gameEndedAt;

  set gameEndedAt(DateTime? value) {
    _gameEndedAt = value;
  }

  Duration _getTotalTime() {
    if (_gameStartedAt == null) {
      return Duration.zero;
    } else {
      final DateTime totalTime = _gameEndedAt ?? DateTime.now();
      return totalTime.difference(_gameStartedAt!);
    }
  }

  /// Comprueba si el resultado actual constituye un nuevo récord.
  @protected
  bool isNewRecord({required int level, required int elapsedMilliseconds}) {
    if (level > _record.maxLevel) {
      return true;
    }
    if (level == _record.maxLevel &&
        (_record.bestTime == 0 || elapsedMilliseconds < _record.bestTime)) {
      return true;
    }
    return false;
  }

  /// Guarda los datos del nuevo récord en la base de datos.
  @protected
  Future<void> saveRecord({
    required int level,
    required int elapsedMilliseconds,
  }) async {
    await _db.saveGameData(
      featureKey: featureKey,
      level: level,
      time: elapsedMilliseconds,
    );
    _record = Record(maxLevel: level, bestTime: elapsedMilliseconds);
    notifyListeners();
  }

  /// Carga el registro de la base de datos.
  @protected
  Future<Record> getRecord() async {
    final Map<String, dynamic> data = await _db.loadGameData(
      featureKey: featureKey,
    );
    final int maxLevel = data['maxLevel'] as int? ?? 0;
    final int bestTime = data['bestTime'] as int? ?? 0;
    return Record(maxLevel: maxLevel, bestTime: bestTime);
  }
}
