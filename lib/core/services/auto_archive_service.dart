// lib/core/services/auto_archive_service.dart
// Serwis automatycznego archiwizowania wydarzeń

import 'package:flutter/foundation.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/episode_repository.dart';
import '../../domain/repositories/event_repository.dart';

class AutoArchiveService {
  final EventRepository eventRepository;
  final EpisodeRepository episodeRepository;

  AutoArchiveService({
    required this.eventRepository,
    required this.episodeRepository,
  });

  /// Sprawdza wszystkie wydarzenia i automatycznie archiwizuje zakończone
  /// Zwraca listę wydarzeń które zostały zarchiwizowane (do pokazania dialogu oceny)
  Future<List<Event>> checkAndArchiveCompletedEvents() async {
    try {
      debugPrint('🔍 Checking for completed events...');

      // Pobierz tylko ongoing wydarzenia (bo upcoming nie mogą być zakończone)
      final ongoingEvents = await eventRepository.getOngoingEvents();

      final completedEvents = <Event>[];

      for (var event in ongoingEvents) {
        // Pomiń wydarzenia bez odcinków
        if (event.totalEpisodes == null || event.totalEpisodes! <= 0) {
          continue;
        }

        // Pomiń już zarchiwizowane
        if (event.status == EventStatus.archived) {
          continue;
        }

        // Sprawdź czy wszystkie odcinki wyemitowane
        if (await _areAllEpisodesAired(event.id!)) {
          debugPrint('✅ Event ${event.title} completed - all episodes aired');

          // Archiwizuj wydarzenie (bez oceny - użytkownik doda później)
          final archivedEvent = event.copyWith(
            status: EventStatus.archived,
            endDate: DateTime.now(), // Ustaw datę zakończenia
            // rating pozostaje null - użytkownik doda
          );

          await eventRepository.updateEvent(archivedEvent);
          completedEvents.add(archivedEvent);
        }
      }

      if (completedEvents.isNotEmpty) {
        debugPrint('📦 Archived ${completedEvents.length} completed events');
      } else {
        debugPrint('ℹ️ No events to archive');
      }

      return completedEvents;
    } catch (e, stackTrace) {
      debugPrint('❌ Error checking completed events: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Sprawdza czy wszystkie odcinki wydarzenia zostały wyemitowane
  Future<bool> _areAllEpisodesAired(int eventId) async {
    try {
      final episodes = await episodeRepository.getEpisodesByEvent(eventId);

      if (episodes.isEmpty) {
        return false;
      }

      final now = DateTime.now();

      // Sprawdź czy WSZYSTKIE odcinki są aired
      // (status aired LUB data+godzina już minęła)
      for (var episode in episodes) {
        // Pomiń przełożone odcinki
        if (episode.status == EpisodeStatus.skipped) {
          continue;
        }

        // Jeśli odcinek jest upcoming I jego data jeszcze nie minęła
        if (episode.status == EpisodeStatus.upcoming) {
          return false;
        }

        // Jeśli odcinek jest aired, sprawdź datę dla pewności
        if (episode.airDate.isAfter(now)) {
          return false;
        }
      }

      // Wszystkie odcinki są aired!
      return true;
    } catch (e) {
      debugPrint('❌ Error checking episodes for event $eventId: $e');
      return false;
    }
  }

  /// Sprawdza pojedyncze wydarzenie czy powinno być zarchiwizowane
  Future<bool> shouldEventBeArchived(Event event) async {
    if (event.id == null) return false;
    if (event.status == EventStatus.archived) return false;
    if (event.totalEpisodes == null || event.totalEpisodes! <= 0) return false;

    return await _areAllEpisodesAired(event.id!);
  }

  /// Archiwizuje wydarzenie z oceną
  Future<void> archiveEventWithRating(Event event, int rating) async {
    final archivedEvent = event.copyWith(
      status: EventStatus.archived,
      rating: rating,
      endDate: event.endDate ?? DateTime.now(),
    );

    await eventRepository.updateEvent(archivedEvent);
    debugPrint('✅ Event ${event.title} archived with rating: $rating');
  }
}