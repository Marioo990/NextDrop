// lib/core/constants/app_constants.dart

class AppConstants {
  static const String databaseName = 'events.db';
  static const int databaseVersion = 3; // ZWIĘKSZ WERSJĘ!
  static const String eventsTable = 'events';
  static const String upcomingEpisodesTable = 'upcoming_episodes';

  // reszta bez zmian...
  static const String keyGlobalNotifications = 'global_notifications';
  static const String keyDefaultNotificationMinutes = 'default_notification_minutes';
  static const String keyDefaultTimeView = 'default_time_view';
  static const int defaultNotificationMinutes = 60;
  static const String defaultTimeView = 'week';
  static const String notificationChannelId = 'event_reminders';
  static const String notificationChannelName = 'Przypomnienia o wydarzeniach';

  static const List<String> defaultCategories = [
    'Komedia', 'Dramat', 'Akcja', 'Sci-Fi', 'Fantasy', 'Horror',
    'Thriller', 'Romans', 'Dokument', 'Edukacja', 'Sport', 'Muzyka',
    'Dzieci', 'Reality Show', 'Talk Show', 'Inne',
  ];

  static const List<String> defaultPlatforms = [
    'Netflix', 'HBO Max', 'Disney+', 'Amazon Prime', 'Apple TV+',
    'YouTube', 'Spotify', 'Polsat', 'TVN', 'TVP', 'Canal+',
    'Player', 'CDA', 'Inne',
  ];
}