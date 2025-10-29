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

  // ✅ POPRAWIONE: Bezpieczna metoda dodawania dni bez problemów ze zmianą czasu
  Future<void> generateEpisodes(
      int eventId,
      DateTime startDate,
      int totalEpisodes,
      int intervalDays,
      TimeOfDay? startTime,
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
    debugPrint('🗑️  Usunięto stare odcinki dla eventu $eventId');

    final now = DateTime.now();

    int successCount = 0;
    int skipCount = 0;

    // ✅ KLUCZOWA ZMIANA: Używamy manipulacji na datach zamiast Duration
    for (int i = 1; i <= totalEpisodes; i++) {
      try {
        // Oblicz ile dni dodać
        final daysToAdd = (i - 1) * intervalDays;

        // ✅ POPRAWKA: Bezpośrednie dodawanie dni do składowych daty
        // DateTime automatycznie normalizuje wartości (np. dzień 32 → następny miesiąc)
        // To zapobiega problemom ze zmianą czasu letni/zimowy!
        final targetDate = DateTime(
          startDate.year,
          startDate.month,
          startDate.day + daysToAdd, // Dodajemy dni bezpośrednio
        );

        // Dodaj godzinę z wydarzenia (jeśli jest)
        final airDate = startTime != null
            ? DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          startTime.hour,
          startTime.minute,
        )
            : DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          0, // Domyślnie północ
          0,
        );

        // Sprawdź czy nie jest zbyt daleko w przyszłości
        final maxDate = now.add(const Duration(days: 365 * 3));
        if (airDate.isAfter(maxDate)) {
          debugPrint('⏩ Odcinek $i ($airDate) jest zbyt daleko, pomijam');
          skipCount++;
          continue;
        }

        // Status aired tylko jeśli PEŁNA data+godzina jest w przeszłości
        final episode = EpisodeModel(
          eventId: eventId,
          episodeNumber: i,
          airDate: airDate,
          status: airDate.isBefore(now)
              ? EpisodeStatus.aired
              : EpisodeStatus.upcoming,
        );

        await createEpisode(episode);
        successCount++;

        // Debug co 10 odcinków
        if (i % 10 == 0 || i == 1) {
          debugPrint('📅 Odcinek $i: ${airDate.day}.${airDate.month}.${airDate.year} ${airDate.hour}:${airDate.minute.toString().padLeft(2, '0')}');
        }
      } catch (e) {
        debugPrint('❌ Błąd przy tworzeniu odcinka $i: $e');
        skipCount++;
      }
    }

    debugPrint('✅ Wygenerowano $successCount odcinków dla eventu $eventId');
    if (skipCount > 0) {
      debugPrint('⚠️  Pominięto $skipCount odcinków');
    }
  }

  Future<void> shiftEpisodesFromNumber(int eventId, int fromEpisode, int intervalDays) async {
    final episodes = await getEpisodesByEvent(eventId);

    for (var episode in episodes) {
      if (episode.episodeNumber >= fromEpisode) {
        // ✅ POPRAWKA: Używamy tej samej metody co w generateEpisodes
        final newDate = DateTime(
          episode.airDate.year,
          episode.airDate.month,
          episode.airDate.day + intervalDays,
          episode.airDate.hour,
          episode.airDate.minute,
        );

        final updatedEpisode = episode.copyWith(airDate: newDate);
        await updateEpisode(EpisodeModel.fromEntity(updatedEpisode));
      }
    }
  }
}