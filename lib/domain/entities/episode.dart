import 'package:equatable/equatable.dart';

enum EpisodeStatus {
  upcoming('upcoming', 'Nadchodzący'),
  aired('aired', 'Wyemitowany'),
  skipped('skipped', 'Pominięty');

  final String value;
  final String displayName;
  const EpisodeStatus(this.value, this.displayName);

  static EpisodeStatus fromString(String value) {
    return EpisodeStatus.values.firstWhere((e) => e.value == value);
  }
}

class Episode extends Equatable {
  final int? id;
  final int eventId;
  final int episodeNumber;
  final DateTime airDate;
  final EpisodeStatus status;
  final bool notificationSent;

  const Episode({
    this.id,
    required this.eventId,
    required this.episodeNumber,
    required this.airDate,
    this.status = EpisodeStatus.upcoming,
    this.notificationSent = false,
  });

  Episode copyWith({
    int? id,
    int? eventId,
    int? episodeNumber,
    DateTime? airDate,
    EpisodeStatus? status,
    bool? notificationSent,
  }) {
    return Episode(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      airDate: airDate ?? this.airDate,
      status: status ?? this.status,
      notificationSent: notificationSent ?? this.notificationSent,
    );
  }

  @override
  List<Object?> get props => [
    id,
    eventId,
    episodeNumber,
    airDate,
    status,
    notificationSent,
  ];
}