// lib/data/repositories/episode_repository_impl.dart

import 'package:flutter/material.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/episode_repository.dart';
import '../datasources/local/episode_local_datasource.dart';
import '../models/episode_model.dart';

class EpisodeRepositoryImpl implements EpisodeRepository {
  final EpisodeLocalDataSource localDataSource;

  EpisodeRepositoryImpl(this.localDataSource);

  @override
  Future<int> createEpisode(Episode episode) async {
    final model = EpisodeModel.fromEntity(episode);
    return await localDataSource.createEpisode(model);
  }

  @override
  Future<Episode?> getEpisodeById(int id) async {
    return await localDataSource.getEpisodeById(id);
  }

  @override
  Future<List<Episode>> getEpisodesByEvent(int eventId) async {
    return await localDataSource.getEpisodesByEvent(eventId);
  }

  @override
  Future<Map<int, List<Episode>>> getEpisodesByMultipleEvents(List<int> eventIds) async {
    return await localDataSource.getEpisodesByMultipleEvents(eventIds);
  }

  @override
  Future<void> updateEpisode(Episode episode) async {
    final model = EpisodeModel.fromEntity(episode);
    await localDataSource.updateEpisode(model);
  }

  @override
  Future<void> deleteEpisode(int id) async {
    await localDataSource.deleteEpisode(id);
  }

  @override
  Future<void> generateEpisodes(
      int eventId,
      DateTime startDate,
      int totalEpisodes,
      int intervalDays,
      TimeOfDay? startTime, // ✅ NOWY PARAMETR
      ) async {
    await localDataSource.generateEpisodes(
      eventId,
      startDate,
      totalEpisodes,
      intervalDays,
      startTime, // ✅ Przekazujemy dalej
    );
  }

  @override
  Future<void> shiftEpisodesFromNumber(int eventId, int fromEpisode, int intervalDays) async {
    await localDataSource.shiftEpisodesFromNumber(eventId, fromEpisode, intervalDays);
  }

  @override
  Future<void> markEpisodeAsSkipped(int episodeId) async {
    final episode = await localDataSource.getEpisodeById(episodeId);
    if (episode != null) {
      final updated = episode.copyWith(status: EpisodeStatus.skipped);
      await localDataSource.updateEpisode(EpisodeModel.fromEntity(updated));
    }
  }

  @override
  Future<void> postponeEpisode(int episodeId, int eventId, int intervalDays) async {
    final episode = await localDataSource.getEpisodeById(episodeId);
    if (episode == null) return;

    final allEpisodes = await localDataSource.getEpisodesByEvent(eventId);

    final nextEpisode = allEpisodes.firstWhere(
          (e) => e.episodeNumber == episode.episodeNumber + 1,
      orElse: () => EpisodeModel(
        eventId: eventId,
        episodeNumber: episode.episodeNumber + 1,
        airDate: episode.airDate.add(Duration(days: intervalDays)),
        status: EpisodeStatus.upcoming,
      ),
    );

    final skippedEpisode = episode.copyWith(status: EpisodeStatus.skipped);
    await localDataSource.updateEpisode(EpisodeModel.fromEntity(skippedEpisode));

    final newEpisode = EpisodeModel(
      eventId: eventId,
      episodeNumber: episode.episodeNumber,
      airDate: nextEpisode.airDate,
      status: EpisodeStatus.upcoming,
      notificationSent: false,
    );
    await localDataSource.createEpisode(newEpisode);

    await localDataSource.shiftEpisodesFromNumber(
      eventId,
      episode.episodeNumber + 1,
      intervalDays,
    );
  }
}