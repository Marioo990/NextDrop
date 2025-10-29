import '../../core/constants/enums.dart';
import '../../core/services/notification_service.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/local/event_local_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventLocalDataSource localDataSource;
  final NotificationService _notificationService = NotificationService.instance;

  EventRepositoryImpl(this.localDataSource);

  @override
  Future<int> createEvent(Event event) async {
    final model = EventModel.fromEntity(event);
    final id = await localDataSource.createEvent(model);

    // Zaplanuj powiadomienie jeśli włączone
    if (event.notificationsEnabled) {
      final eventWithId = event.copyWith(id: id);
      await _notificationService.scheduleEventNotification(eventWithId);
    }

    return id;
  }

  @override
  Future<Event?> getEventById(int id) async {
    return await localDataSource.getEventById(id);
  }

  @override
  Future<void> updateEvent(Event event) async {
    final model = EventModel.fromEntity(event);
    await localDataSource.updateEvent(model);

    // Zaktualizuj powiadomienie
    if (event.id != null) {
      await _notificationService.cancelEventNotification(event.id!);
      if (event.notificationsEnabled) {
        await _notificationService.scheduleEventNotification(event);
      }
    }
  }

  @override
  Future<void> deleteEvent(int id) async {
    await _notificationService.cancelEventNotification(id);
    await localDataSource.deleteEvent(id);
  }

  @override
  Future<List<Event>> getAllEvents() async {
    return await localDataSource.getAllEvents();
  }

  @override
  Future<List<Event>> getEventsByStatus(EventStatus status) async {
    return await localDataSource.getEventsByStatus(status);
  }

  @override
  Future<List<Event>> getEventsBetweenDates({
    required DateTime startDate,
    required DateTime endDate,
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
  }) async {
    return await localDataSource.getEventsBetweenDates(
      startDate: startDate,
      endDate: endDate,
      typeFilter: typeFilter,
      platformFilter: platformFilter,
      categoryFilter: categoryFilter,
    );
  }

  @override
  Future<List<Event>> getUpcomingEvents({
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
  }) async {
    return await localDataSource.getFilteredEvents(
      status: EventStatus.upcoming,
      typeFilter: typeFilter,
      platformFilter: platformFilter,
      categoryFilter: categoryFilter,
    );
  }

  @override
  Future<List<Event>> getOngoingEvents({
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
  }) async {
    return await localDataSource.getFilteredEvents(
      status: EventStatus.ongoing,
      typeFilter: typeFilter,
      platformFilter: platformFilter,
      categoryFilter: categoryFilter,
    );
  }

  @override
  Future<List<Event>> getArchivedEvents({
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
    int? minRating,
  }) async {
    return await localDataSource.getFilteredEvents(
      status: EventStatus.archived,
      typeFilter: typeFilter,
      platformFilter: platformFilter,
      categoryFilter: categoryFilter,
      minRating: minRating,
    );
  }

  @override
  Future<List<String>> getAllPlatforms() async {
    return await localDataSource.getAllPlatforms();
  }

  @override
  Future<List<String>> getAllCategories() async {
    return await localDataSource.getAllCategories();
  }
}