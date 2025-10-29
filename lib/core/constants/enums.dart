enum EventType {
  series('Serial', 'series'),
  anime('Anime', 'anime'),
  podcast('Podcast', 'podcast'),
  tvShow('Program TV', 'tvShow'),
  movie('Film', 'movie');

  final String displayName;
  final String value;
  const EventType(this.displayName, this.value);

  static EventType fromString(String value) {
    return EventType.values.firstWhere((e) => e.value == value);
  }
}

enum EventStatus {
  upcoming('Przyszłe', 'upcoming'),
  ongoing('W trakcie', 'ongoing'),
  archived('Zakończone', 'archived');

  final String displayName;
  final String value;
  const EventStatus(this.displayName, this.value);

  static EventStatus fromString(String value) {
    return EventStatus.values.firstWhere((e) => e.value == value);
  }
}

enum Recurrence {
  once('Jednorazowe', 'once'),
  daily('Codziennie', 'daily'),
  weekly('Co tydzień', 'weekly'),
  biweekly('Co 2 tygodnie', 'biweekly'),
  monthly('Co miesiąc', 'monthly'),
  custom('Niestandardowe', 'custom'),
  batch('Pakiet', 'batch');

  final String displayName;
  final String value;
  const Recurrence(this.displayName, this.value);

  static Recurrence fromString(String value) {
    return Recurrence.values.firstWhere((e) => e.value == value);
  }
}

enum WeekDay {
  monday('Poniedziałek', 0),
  tuesday('Wtorek', 1),
  wednesday('Środa', 2),
  thursday('Czwartek', 3),
  friday('Piątek', 4),
  saturday('Sobota', 5),
  sunday('Niedziela', 6);

  final String displayName;
  final int value;
  const WeekDay(this.displayName, this.value);

  static WeekDay fromInt(int value) {
    return WeekDay.values.firstWhere((e) => e.value == value);
  }
}

enum TimeView {
  day('Dzień', 'day'),
  week('Tydzień', 'week'),
  month('Miesiąc', 'month');

  final String displayName;
  final String value;
  const TimeView(this.displayName, this.value);

  static TimeView fromString(String value) {
    return TimeView.values.firstWhere((e) => e.value == value);
  }
}