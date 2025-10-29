// lib/data/datasources/local/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: 3, // ZWIĘKSZ WERSJĘ!
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    debugPrint('📦 Creating database version $version');

    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textTypeNullable = 'TEXT';
    const intTypeNullable = 'INTEGER';

    await db.execute('''
      CREATE TABLE ${AppConstants.eventsTable} (
        id $idType,
        title $textType,
        start_date $intType,
        start_time $textTypeNullable,
        recurrence $textType,
        recurrence_interval $intTypeNullable,
        recurrence_day $intTypeNullable,
        batch_size $intTypeNullable,
        type $textType,
        category $textType,
        platform $textType,
        image_path $textTypeNullable,
        publisher $textTypeNullable,
        description $textTypeNullable,
        user_note $textTypeNullable,
        notifications_enabled $intType DEFAULT 1,
        notification_minutes $intTypeNullable,
        status $textType DEFAULT 'upcoming',
        rating $intTypeNullable,
        end_date $intTypeNullable,
        total_episodes $intTypeNullable,
        created_at $intType,
        updated_at $intType
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_events_status ON ${AppConstants.eventsTable}(status)'
    );
    await db.execute(
        'CREATE INDEX idx_events_type ON ${AppConstants.eventsTable}(type)'
    );
    await db.execute(
        'CREATE INDEX idx_events_platform ON ${AppConstants.eventsTable}(platform)'
    );
    await db.execute(
        'CREATE INDEX idx_events_category ON ${AppConstants.eventsTable}(category)'
    );
    await db.execute(
        'CREATE INDEX idx_events_start_date ON ${AppConstants.eventsTable}(start_date)'
    );

    // Tabela nadchodzących odcinków - DODAJ status!
    await db.execute('''
      CREATE TABLE ${AppConstants.upcomingEpisodesTable} (
        id $idType,
        event_id $intType,
        episode_number $intType,
        air_date $intType,
        status $textType DEFAULT 'upcoming',
        notification_sent $intType DEFAULT 0,
        FOREIGN KEY (event_id) REFERENCES ${AppConstants.eventsTable}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_episodes_event ON ${AppConstants.upcomingEpisodesTable}(event_id)'
    );
    await db.execute(
        'CREATE INDEX idx_episodes_date ON ${AppConstants.upcomingEpisodesTable}(air_date)'
    );

    debugPrint('✅ Database created successfully');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Upgrading database from v$oldVersion to v$newVersion');

    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE ${AppConstants.eventsTable} ADD COLUMN total_episodes INTEGER'
      );
      debugPrint('✅ Added total_episodes column to events');
    }

    if (oldVersion < 3) {
      // Dodaj kolumnę status do upcoming_episodes
      try {
        await db.execute(
            'ALTER TABLE ${AppConstants.upcomingEpisodesTable} ADD COLUMN status TEXT DEFAULT "upcoming"'
        );
        debugPrint('✅ Added status column to upcoming_episodes');
      } catch (e) {
        debugPrint('⚠️ Column status may already exist: $e');
      }
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> query(
      String table, {
        String? where,
        List<dynamic>? whereArgs,
        String? orderBy,
      }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    debugPrint('🗑️ Database deleted');
  }
}