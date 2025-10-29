// lib/data/datasources/local/episode_local_datasource.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/episode.dart';
import '../../models/episode_model.dart';
import 'database_helper.dart';
import 'package:flutter/foundation.dart';

class EpisodeLocalDataSource {
  final DatabaseHelper dbHelper;

  static const int maxEpisodes = 500;
  static const int maxIntervalDays = 365;

  EpisodeLocalDataSource(this.dbHelper);

  Future<int> createEpisode(EpisodeModel episode) async {
    return await dbHelper.insert(AppConstants.upcomingEpisodesTable, episode.toMap());
  }

  Future<List<EpisodeModel>> getEpisodesByEvent(int eventId) async {
    final result = await dbHelper.query(
      AppConstants.upcomingEpisodesTable,
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'episode_number ASC',
    );
    return result.map((json) => EpisodeModel.fromMap(json)).toList();
  }

  Future<Map<int, List<EpisodeModel>>> getEpisodesByMultipleEvents(
      List<int> eventIds,
      ) async {
    if (eventIds.isEmpty) return {};

    final db = await dbHelper.database;

    final placeholders = List.filled(eventIds.length, '?').join(',');

    final result = await db.query(
      AppConstants.upcomingEpisodesTable,
      where: 'event_id IN ($placeholders)',
      whereArgs: eventIds,
      orderBy: 'episode_number ASC',
    );

    final Map<int, List<EpisodeModel>> grouped = {};

    for (var row in result) {
      final episode = EpisodeModel.fromMap(row);
      final eventId = episode.eventId;

      if (!grouped.containsKey(eventId)) {
        grouped[eventId] = [];
      }
      grouped[eventId]!.add(episode);
    }

    debugPrint('Loaded episodes for ${grouped.length} events in one query');
    return grouped;
  }

  Future<EpisodeModel?> getEpisodeById(int id) async {
    final result = await dbHelper.query(
      AppConstants.upcomingEpisodesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return EpisodeModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateEpisode(EpisodeModel episode) async {
    return await dbHelper.update(AppConstants.upcomingEpisodesTable, episode.toMap());
  }

  Future<int> deleteEpisode(int id) async {
    return await dbHelper.delete(AppConstants.upcomingEpisodesTable, id);
  }

  Future<void> deleteEpisodesByEvent(int eventId) async {
    final db = await dbHelper.database;
    await db.delete(
      AppConstants.upcomingEpisodesTable,
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
  }

  // ✅ ZMIENIONE: Dodano parametr startTime i używamy go przy tworzeniu odcinków
  Future<void> generateEpisodes(
      int eventId,
      DateTime startDate,
      int totalEpisodes,
      int intervalDays,
      TimeOfDay? startTime, // ✅ NOWY PARAMETR
      ) async {
    if (totalEpisodes <= 0) {
      throw ArgumentError('Liczba odcinków musi być większa od 0');
    }

    if (totalEpisodes > maxEpisodes) {
      throw ArgumentError('Maksymalna liczba odcinków to $maxEpisodes');
    }

    if (intervalDays < 0 || intervalDays > maxIntervalDays) {
      throw ArgumentError('Interwał musi być między 0 a $maxIntervalDays dni');
    }

    await deleteEpisodesByEvent(eventId);
    debugPrint('Usunięto stare odcinki dla eventu $eventId');

    // ✅ ZMIENIONE: Używamy pełnego DateTime z godziną
    final now = DateTime.now();

    int successCount = 0;
    int skipCount = 0;

    for (int i = 1; i <= totalEpisodes; i++) {
      try {
        // Dodaj dni do daty startowej
        final dateOnly = startDate.add(Duration(days: (i - 1) * intervalDays));

        // ✅ NOWE: Dodaj godzinę z wydarzenia (jeśli jest)
        final airDate = startTime != null
            ? DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          startTime.hour,
          startTime.minute,
        )
            : DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          0, // Domyślnie północ
          0,
        );

        final maxDate = now.add(const Duration(days: 365 * 3));
        if (airDate.isAfter(maxDate)) {
          debugPrint('Odcinek $i ($airDate) jest zbyt daleko, pomijam');
          skipCount++;
          continue;
        }

        // ✅ ZMIENIONE: Status aired tylko jeśli PEŁNA data+godzina jest w przeszłości
        final episode = EpisodeModel(
          eventId: eventId,
          episodeNumber: i,
          airDate: airDate, // ✅ Teraz zawiera godzinę!
          status: airDate.isBefore(now) // ✅ Porównanie z pełnym DateTime
              ? EpisodeStatus.aired
              : EpisodeStatus.upcoming,
        );

        await createEpisode(episode);
        successCount++;
      } catch (e) {
        debugPrint('Błąd przy tworzeniu odcinka $i: $e');
        skipCount++;
      }
    }

    debugPrint('Wygenerowano $successCount odcinków dla eventu $eventId');
    if (skipCount > 0) {
      debugPrint('Pominięto $skipCount odcinków');
    }
  }

  Future<void> shiftEpisodesFromNumber(int eventId, int fromEpisode, int intervalDays) async {
    final episodes = await getEpisodesByEvent(eventId);

    for (var episode in episodes) {
      if (episode.episodeNumber >= fromEpisode) {
        final updatedEpisode = episode.copyWith(
          airDate: episode.airDate.add(Duration(days: intervalDays)),
        );
        await updateEpisode(EpisodeModel.fromEntity(updatedEpisode));
      }
    }
  }
}