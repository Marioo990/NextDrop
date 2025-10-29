import '../entities/event.dart';
import '../../core/constants/enums.dart';

abstract class EventRepository {
  // CRUD Operations
  Future<int> createEvent(Event event);
  Future<Event?> getEventById(int id);
  Future<void> updateEvent(Event event);
  Future<void> deleteEvent(int id);

  // Query Operations
  Future<List<Event>> getAllEvents();
  Future<List<Event>> getEventsByStatus(EventStatus status);

  Future<List<Event>> getEventsBetweenDates({
    required DateTime startDate,
    required DateTime endDate,
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
  });

  Future<List<Event>> getUpcomingEvents({
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
  });

  Future<List<Event>> getOngoingEvents({
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
  });

  Future<List<Event>> getArchivedEvents({
    EventType? typeFilter,
    String? platformFilter,
    String? categoryFilter,
    int? minRating,
  });

  // Helper Methods
  Future<List<String>> getAllPlatforms();
  Future<List<String>> getAllCategories();
}