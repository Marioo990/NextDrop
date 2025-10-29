// lib/domain/repositories/episode_repository.dart

import 'package:flutter/material.dart';
import '../entities/episode.dart';

abstract class EpisodeRepository {
  Future<int> createEpisode(Episode episode);
  Future<Episode?> getEpisodeById(int id);
  Future<List<Episode>> getEpisodesByEvent(int eventId);
  Future<Map<int, List<Episode>>> getEpisodesByMultipleEvents(List<int> eventIds);
  Future<void> updateEpisode(Episode episode);
  Future<void> deleteEpisode(int id);

  // ✅ ZMIENIONE: Dodano parametr startTime
  Future<void> generateEpisodes(
      int eventId,
      DateTime startDate,
      int totalEpisodes,
      int intervalDays,
      TimeOfDay? startTime, // ✅ NOWY PARAMETR
      );

  Future<void> shiftEpisodesFromNumber(int eventId, int fromEpisode, int intervalDays);
  Future<void> markEpisodeAsSkipped(int episodeId);
  Future<void> postponeEpisode(int episodeId, int eventId, int intervalDays);
}