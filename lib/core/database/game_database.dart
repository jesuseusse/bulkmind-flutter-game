import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GameDataBase {
  static final GameDataBase _instance = GameDataBase._internal();
  factory GameDataBase() => _instance;
  GameDataBase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'game_records.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            featureKey TEXT UNIQUE,
            level INTEGER,
            time INTEGER
          )
        ''');
      },
    );
  }

  /// Check if the new score is a record
  Future<bool> isNewRecord({
    required String featureKey,
    required int level,
    required int time,
  }) async {
    final db = await database;
    final result = await db.query(
      'records',
      where: 'featureKey = ?',
      whereArgs: [featureKey],
      limit: 1,
    );

    if (result.isEmpty) return true;

    final currentMaxLevel = result.first['level'] as int;
    final currentBestTime = result.first['time'] as int;
    return level > currentMaxLevel ||
        (level == currentMaxLevel && time < currentBestTime);
  }

  /// Save game data with featureKey, level, and time.
  Future<void> saveGameData({
    required String featureKey,
    required int level,
    required int time,
  }) async {
    final db = await database;

    if (await isNewRecord(featureKey: featureKey, level: level, time: time)) {
      final existing = await db.query(
        'records',
        where: 'featureKey = ?',
        whereArgs: [featureKey],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        await db.update(
          'records',
          {'level': level, 'time': time},
          where: 'featureKey = ?',
          whereArgs: [featureKey],
        );
      } else {
        await db.insert('records', {
          'featureKey': featureKey,
          'level': level,
          'time': time,
        });
      }
    }
  }

  /// Load saved game data by featureKey
  Future<Map<String, dynamic>> loadGameData({
    required String featureKey,
  }) async {
    final db = await database;
    final result = await db.query(
      'records',
      where: 'featureKey = ?',
      whereArgs: [featureKey],
      limit: 1,
    );

    if (result.isEmpty) {
      return {'maxLevel': 0, 'bestTime': 0};
    }

    final row = result.first;
    return {'maxLevel': row['level'] as int, 'bestTime': row['time'] as int};
  }
}
