
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
import '../../models/event_model.dart';
import 'database_helper.dart';

class EventLocalDataSource {
  final DatabaseHelper dbHelper;

  EventLocalDataSource(this.dbHelper);

  Future<int> createEvent(EventModel event) async {
    return await dbHelper.insert(AppConstants.eventsTable, event.toMap());
  }

  Future<List<EventModel>> getAllEvents() async {
    final result = await dbHelper.query(
      AppConstants.eventsTable,
      orderBy: 'start_date ASC',
    );
    return result.map((json) => EventModel.fromMap(json)).toList();
  }

  Future<EventModel?> getEventById(int id) async {
    final result = await dbHelper.query(
      AppConstants.eventsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return EventModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<EventModel>> getEventsByStatus(EventStatus status) async {
    final result = await dbHelper.query(
      AppConstants.eventsTable,
      where: 'status = ?',
      whereArgs: [status.value],
      orderBy: 'start_date ASC',
    );
    return result.map((json) => EventModel.fromMap(json)).toList();
  }

  Future<List<EventModel>> getEventsBetweenDates({
    required DateTime startDate,
    required DateTime endDate,
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
  }) async {
    String where = 'start_date >= ? AND start_date < ?';
    List<dynamic> whereArgs = [
      startDate.millisecondsSinceEpoch,
      endDate.millisecondsSinceEpoch,
    ];

    if (typeFilter != null) {
      where += ' AND type = ?';
      whereArgs.add(typeFilter.value);
    }

    if (platformFilter != null && platformFilter.isNotEmpty) {
      where += ' AND platform = ?';
      whereArgs.add(platformFilter);
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      where += ' AND category = ?';
      whereArgs.add(categoryFilter);
    }

    final result = await dbHelper.query(
      AppConstants.eventsTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'start_date ASC',
    );

    return result.map((json) => EventModel.fromMap(json)).toList();
  }

  Future<List<EventModel>> getFilteredEvents({
    EventStatus? status,
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
    int? minRating,
  }) async {
    String? where;
    List<dynamic> whereArgs = [];

    if (status != null) {
      where = 'status = ?';
      whereArgs.add(status.value);
    }

    if (typeFilter != null) {
      where = where == null ? 'type = ?' : '$where AND type = ?';
      whereArgs.add(typeFilter.value);
    }

    if (platformFilter != null && platformFilter.isNotEmpty) {
      where = where == null ? 'platform = ?' : '$where AND platform = ?';
      whereArgs.add(platformFilter);
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      where = where == null ? 'category = ?' : '$where AND category = ?';
      whereArgs.add(categoryFilter);
    }

    if (minRating != null) {
      where = where == null ? 'rating >= ?' : '$where AND rating >= ?';
      whereArgs.add(minRating);
    }

    final result = await dbHelper.query(
      AppConstants.eventsTable,
      where: where,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'start_date DESC',
    );

    return result.map((json) => EventModel.fromMap(json)).toList();
  }

  Future<int> updateEvent(EventModel event) async {
    return await dbHelper.update(AppConstants.eventsTable, event.toMap());
  }

  Future<int> deleteEvent(int id) async {
    return await dbHelper.delete(AppConstants.eventsTable, id);
  }

  Future<List<String>> getAllPlatforms() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
        'SELECT DISTINCT platform FROM ${AppConstants.eventsTable} ORDER BY platform ASC'
    );
    return result.map((row) => row['platform'] as String).toList();
  }

  Future<List<String>> getAllCategories() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
        'SELECT DISTINCT category FROM ${AppConstants.eventsTable} ORDER BY category ASC'
    );
    return result.map((row) => row['category'] as String).toList();
  }
}