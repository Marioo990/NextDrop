import 'package:flutter/foundation.dart';
import '../../domain/entities/episode.dart';

class EpisodeModel extends Episode {
  const EpisodeModel({
    super.id,
    required super.eventId,
    required super.episodeNumber,
    required super.airDate,
    super.status = EpisodeStatus.upcoming,
    super.notificationSent = false,
  });

  factory EpisodeModel.fromEntity(Episode episode) {
    return EpisodeModel(
      id: episode.id,
      eventId: episode.eventId,
      episodeNumber: episode.episodeNumber,
      airDate: episode.airDate,
      status: episode.status,
      notificationSent: episode.notificationSent,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'event_id': eventId,
      'episode_number': episodeNumber,
      'air_date': airDate.millisecondsSinceEpoch,
      'status': status.value,
      'notification_sent': notificationSent ? 1 : 0,
    };
    // if (kDebugMode) {
    //   // 🔍 DEBUG: Co zapisujemy do bazy?
    //   debugPrint('💾 Zapis do bazy - Odcinek $episodeNumber:');
    //   debugPrint('   airDate: $airDate');
    //   debugPrint('   milliseconds: ${airDate.millisecondsSinceEpoch}');
    // }
    return map;
  }

  factory EpisodeModel.fromMap(Map<String, dynamic> map) {
    final milliseconds = map['air_date'] as int;
    final airDate = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    // if (kDebugMode) {
    //   // 🔍 DEBUG: Co odczytujemy z bazy?
    //   debugPrint('📖 Odczyt z bazy - Odcinek ${map['episode_number']}:');
    //   debugPrint('   milliseconds z bazy: $milliseconds');
    //   debugPrint('   airDate po konwersji: $airDate');
    //   debugPrint('   Godzina: ${airDate.hour}:${airDate.minute}');
    // }
    return EpisodeModel(
      id: map['id'] as int?,
      eventId: map['event_id'] as int,
      episodeNumber: map['episode_number'] as int,
      airDate: airDate,
      status: EpisodeStatus.fromString(map['status'] as String),
      notificationSent: (map['notification_sent'] as int) == 1,
    );
  }
}