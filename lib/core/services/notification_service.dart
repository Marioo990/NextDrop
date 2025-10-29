
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/event.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicjalizacja serwisu powiadomień
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Utwórz kanał powiadomień dla Androida
    const androidChannel = AndroidNotificationChannel(
      'event_reminders',
      'Przypomnienia o wydarzeniach',
      description: 'Powiadomienia o nadchodzących premierach',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Obsługa kliknięcia w powiadomienie
  void _onNotificationTapped(NotificationResponse response) {
    // Tutaj możesz dodać nawigację do szczegółów wydarzenia
    // Na przykład używając navigation service lub deep linking
    print('Notification tapped: ${response.payload}');
  }

  /// Zaplanuj powiadomienie dla wydarzenia
  Future<void> scheduleEventNotification(Event event) async {
    if (!event.notificationsEnabled || event.notificationMinutes == null) {
      return;
    }

    await initialize();

    // Oblicz czas powiadomienia
    DateTime notificationTime = event.startDate;

    if (event.startTime != null) {
      notificationTime = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
        event.startTime!.hour,
        event.startTime!.minute,
      );
    }

    // Odejmij czas przed wydarzeniem
    notificationTime = notificationTime.subtract(
      Duration(minutes: event.notificationMinutes!),
    );

    // Sprawdź czy czas jest w przyszłości
    if (notificationTime.isBefore(DateTime.now())) {
      return;
    }

    // Zaplanuj powiadomienie
    await _notifications.zonedSchedule(
      event.id!, // ID powiadomienia = ID wydarzenia
      'Zbliża się: ${event.title}',
      'Premiera za ${_formatMinutes(event.notificationMinutes!)} na ${event.platform}',
      tz.TZDateTime.from(notificationTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Przypomnienia o wydarzeniach',
          channelDescription: 'Powiadomienia o nadchodzących premierach',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: event.imagePath != null
              ? FilePathAndroidBitmap(event.imagePath!)
              : null,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: event.id.toString(),
    );
  }

  /// Anuluj powiadomienie dla wydarzenia
  Future<void> cancelEventNotification(int eventId) async {
    await initialize();
    await _notifications.cancel(eventId);
  }

  /// Anuluj wszystkie powiadomienia
  Future<void> cancelAllNotifications() async {
    await initialize();
    await _notifications.cancelAll();
  }

  /// Sprawdź czy powiadomienia są włączone
  Future<bool> areNotificationsEnabled() async {
    if (!_initialized) await initialize();

    final android = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }

    return true;
  }

  /// Poproś o uprawnienia (iOS)
  Future<bool> requestPermissions() async {
    await initialize();

    final ios = _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (ios != null) {
      return await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ) ?? false;
    }

    return true;
  }

  /// Pobierz listę zaplanowanych powiadomień
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await initialize();
    return await _notifications.pendingNotificationRequests();
  }

  /// Formatuj minuty na czytelny string
  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes == 60) {
      return '1 godzinę';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours ${hours == 1 ? 'godzinę' : 'godzin'}';
    } else {
      final days = minutes ~/ 1440;
      return '$days ${days == 1 ? 'dzień' : 'dni'}';
    }
  }
}