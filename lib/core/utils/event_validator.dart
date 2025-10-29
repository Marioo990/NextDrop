import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/event.dart';

class EventValidator {
  static String? validateStartDate(DateTime startDate, EventStatus status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);

    switch (status) {
      case EventStatus.upcoming:
      // POPRAWKA: Dzisiejsza data jest OK dla upcoming
        if (startDateOnly.isBefore(today)) {
          return 'Wydarzenia "Nadchodzące" nie mogą mieć daty w przeszłości';
        }
        break;

      case EventStatus.ongoing:
        final twoYearsAgo = today.subtract(const Duration(days: 730));
        if (startDateOnly.isAfter(today)) {
          return 'Wydarzenia "W trakcie" nie mogą zaczynać się w przyszłości';
        }
        if (startDateOnly.isBefore(twoYearsAgo)) {
          return 'Data rozpoczęcia nie może być starsza niż 2 lata';
        }
        break;

      case EventStatus.archived:
      // POPRAWKA: Archived musi być minimum wczoraj
        if (!startDateOnly.isBefore(today)) {
          return 'Zarchiwizowane wydarzenia muszą być z przeszłości';
        }
        break;
    }

    final maxFutureDate = today.add(const Duration(days: 730));
    if (startDateOnly.isAfter(maxFutureDate)) {
      return 'Data nie może być dalej niż 2 lata w przyszłości';
    }

    return null;
  }

  static String? validateEndDate(DateTime? endDate, DateTime startDate) {
    if (endDate == null) return null;

    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);

    if (endDateOnly.isBefore(startDateOnly)) {
      return 'Data zakończenia nie może być wcześniejsza niż data rozpoczęcia';
    }

    if (endDateOnly.isAtSameMomentAs(startDateOnly)) {
      return 'Data zakończenia musi być późniejsza niż data rozpoczęcia';
    }

    final maxDuration = startDateOnly.add(const Duration(days: 1825));
    if (endDateOnly.isAfter(maxDuration)) {
      return 'Różnica między datami nie może przekraczać 5 lat';
    }

    return null;
  }

  static Map<String, String> validateEvent(Event event) {
    final errors = <String, String>{};

    if (event.title.trim().isEmpty) {
      errors['title'] = 'Tytuł jest wymagany';
    } else if (event.title.trim().length < 2) {
      errors['title'] = 'Tytuł musi mieć co najmniej 2 znaki';
    } else if (event.title.length > 100) {
      errors['title'] = 'Tytuł nie może być dłuższy niż 100 znaków';
    }

    final startDateError = validateStartDate(event.startDate, event.status);
    if (startDateError != null) {
      errors['startDate'] = startDateError;
    }

    if (event.endDate != null) {
      final endDateError = validateEndDate(event.endDate, event.startDate);
      if (endDateError != null) {
        errors['endDate'] = endDateError;
      }
    }

    if (event.notificationsEnabled && event.notificationMinutes == null) {
      errors['notification'] = 'Musisz wybrać czas powiadomienia';
    }

    if (event.notificationMinutes != null && event.notificationMinutes! < 0) {
      errors['notification'] = 'Czas powiadomienia nie może być ujemny';
    }

    if (event.recurrence == Recurrence.weekly && event.recurrenceDay == null) {
      errors['recurrenceDay'] = 'Wybierz dzień tygodnia dla wydarzeń cotygodniowych';
    }

    if (event.recurrence == Recurrence.custom && event.recurrenceInterval == null) {
      errors['recurrenceInterval'] = 'Podaj interwał dla niestandardowej cykliczności';
    }

    if (event.recurrence == Recurrence.batch) {
      if (event.batchSize == null || event.batchSize! <= 0) {
        errors['batchSize'] = 'Podaj liczbę odcinków w pakiecie';
      }
      if (event.recurrenceInterval == null || event.recurrenceInterval! <= 0) {
        errors['recurrenceInterval'] = 'Podaj interwał między pakietami';
      }
    }

    if (event.totalEpisodes != null && event.totalEpisodes! <= 0) {
      errors['totalEpisodes'] = 'Liczba odcinków musi być większa od 0';
    }

    if (event.totalEpisodes != null && event.totalEpisodes! > 999) {
      errors['totalEpisodes'] = 'Liczba odcinków nie może przekraczać 999';
    }

    if (event.rating != null && (event.rating! < 1 || event.rating! > 10)) {
      errors['rating'] = 'Ocena musi być w zakresie 1-10';
    }

    if (event.status == EventStatus.archived) {
      if (event.rating == null) {
        errors['rating'] = 'Zarchiwizowane wydarzenie musi mieć ocenę';
      }
      if (event.endDate == null) {
        errors['endDate'] = 'Zarchiwizowane wydarzenie musi mieć datę zakończenia';
      }
    }

    return errors;
  }

  // POPRAWKA: Bardziej elastyczna logika
  static EventStatus suggestStatus(DateTime startDate, DateTime? endDate) {
    final now = DateTime.now();
    final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);

    if (endDate != null) {
      final endDateOnly = DateTime(endDate.year, endDate.month, endDate.day);
      if (endDateOnly.isBefore(today)) {
        return EventStatus.archived;
      }
    }

    // POPRAWKA: Dzisiejsza data -> ongoing
    if (startDateOnly.isBefore(today) || startDateOnly.isAtSameMomentAs(today)) {
      return EventStatus.ongoing;
    }

    return EventStatus.upcoming;
  }

  static String? validateNotificationTime(
      DateTime eventDate,
      TimeOfDay? eventTime,
      int? notificationMinutes,
      ) {
    if (notificationMinutes == null) return null;

    DateTime eventDateTime = eventDate;
    if (eventTime != null) {
      eventDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        eventTime.hour,
        eventTime.minute,
      );
    }

    final notificationDateTime = eventDateTime.subtract(
      Duration(minutes: notificationMinutes),
    );

    if (notificationDateTime.isBefore(DateTime.now())) {
      return 'Czas powiadomienia jest w przeszłości. Dostosuj datę wydarzenia lub czas powiadomienia.';
    }

    return null;
  }
}