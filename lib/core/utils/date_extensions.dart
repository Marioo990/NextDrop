import 'package:flutter/material.dart';

extension DateTimeExtensions on DateTime {
  /// Zwraca DateTime z zerową godziną
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// Sprawdza czy data jest dzisiaj
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Sprawdza czy data jest jutro
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Sprawdza czy data jest w tym tygodniu
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return isAfter(startOfWeek.dateOnly.subtract(const Duration(seconds: 1))) &&
        isBefore(endOfWeek.dateOnly);
  }

  /// Sprawdza czy data jest w tym miesiącu
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Zwraca początek tygodnia (poniedziałek)
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).dateOnly;
  }

  /// Zwraca koniec tygodnia (niedziela)
  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 7));
  }

  /// Zwraca początek miesiąca
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// Zwraca koniec miesiąca
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59);
  }

  /// Formatuje datę jako relatywny string (np. "Dzisiaj", "Jutro", "Za 2 dni")
  String toRelativeString() {
    final now = DateTime.now();
    final difference = dateOnly.difference(now.dateOnly).inDays;

    if (difference == 0) return 'Dzisiaj';
    if (difference == 1) return 'Jutro';
    if (difference == -1) return 'Wczoraj';
    if (difference > 1 && difference <= 7) return 'Za $difference dni';
    if (difference < -1 && difference >= -7) return '${-difference} dni temu';

    return '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';
  }
}

extension TimeOfDayExtensions on TimeOfDay {
  /// Konwertuje TimeOfDay na DateTime (używając dzisiejszej daty)
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Formatuje czas w formacie 24h
  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}