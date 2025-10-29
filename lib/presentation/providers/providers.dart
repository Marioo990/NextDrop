// lib/presentation/providers/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/event_local_datasource.dart';
import '../../data/datasources/local/episode_local_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/episode_repository_impl.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/episode.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/episode_repository.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final eventLocalDataSourceProvider = Provider<EventLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return EventLocalDataSource(dbHelper);
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final localDataSource = ref.watch(eventLocalDataSourceProvider);
  return EventRepositoryImpl(localDataSource);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('SettingsRepository must be overridden');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository repository;

  SettingsNotifier(this.repository) : super(
    AppSettings(
      globalNotificationsEnabled: repository.getGlobalNotifications(),
      defaultNotificationMinutes: repository.getDefaultNotificationMinutes(),
      defaultTimeView: repository.getDefaultTimeView(),
    ),
  );

  Future<void> setGlobalNotifications(bool value) async {
    await repository.setGlobalNotifications(value);
    state = state.copyWith(globalNotificationsEnabled: value);
  }

  Future<void> setDefaultNotificationMinutes(int minutes) async {
    await repository.setDefaultNotificationMinutes(minutes);
    state = state.copyWith(defaultNotificationMinutes: minutes);
  }

  Future<void> setDefaultTimeView(TimeView timeView) async {
    await repository.setDefaultTimeView(timeView);
    state = state.copyWith(defaultTimeView: timeView);
  }
}

class AppSettings {
  final bool globalNotificationsEnabled;
  final int defaultNotificationMinutes;
  final TimeView defaultTimeView;

  AppSettings({
    required this.globalNotificationsEnabled,
    required this.defaultNotificationMinutes,
    required this.defaultTimeView,
  });

  AppSettings copyWith({
    bool? globalNotificationsEnabled,
    int? defaultNotificationMinutes,
    TimeView? defaultTimeView,
  }) {
    return AppSettings(
      globalNotificationsEnabled: globalNotificationsEnabled ?? this.globalNotificationsEnabled,
      defaultNotificationMinutes: defaultNotificationMinutes ?? this.defaultNotificationMinutes,
      defaultTimeView: defaultTimeView ?? this.defaultTimeView,
    );
  }
}

final currentTimeViewProvider = StateProvider<TimeView>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.defaultTimeView;
});

class FilterParams {
  final EventType? type;
  final String? platform;
  final String? category;
  final int? minRating;

  FilterParams({
    this.type,
    this.platform,
    this.category,
    this.minRating,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FilterParams &&
              runtimeType == other.runtimeType &&
              type == other.type &&
              platform == other.platform &&
              category == other.category &&
              minRating == other.minRating;

  @override
  int get hashCode =>
      type.hashCode ^
      platform.hashCode ^
      category.hashCode ^
      minRating.hashCode;
}

final currentFiltersProvider = StateProvider<FilterParams>((ref) {
  return FilterParams();
});

final eventsRefreshTriggerProvider = StateProvider<int>((ref) => 0);

void refreshAllEvents(WidgetRef ref) {
  ref.read(eventsRefreshTriggerProvider.notifier).update((state) => state + 1);
}

void invalidateAllEventProviders(WidgetRef ref) {
  ref.invalidate(homeEventsProvider);
  ref.invalidate(upcomingEventsProvider);
  ref.invalidate(ongoingEventsProvider);
  ref.invalidate(archivedEventsProvider);
}

final clockTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream.periodic(
    const Duration(minutes: 1),
        (_) => DateTime.now(),
  );
});

class _EventWithNextEpisode {
  final Event event;
  final DateTime? nextEpisodeDate;

  _EventWithNextEpisode(this.event, this.nextEpisodeDate);
}

final homeEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  ref.watch(eventsRefreshTriggerProvider);

  final repository = ref.watch(eventRepositoryProvider);
  final episodeRepository = ref.watch(episodeRepositoryProvider);
  final timeView = ref.watch(currentTimeViewProvider);
  final filters = ref.watch(currentFiltersProvider);
  final now = DateTime.now();

  final upcomingEvents = await repository.getUpcomingEvents(
    typeFilter: filters.type,
    platformFilter: filters.platform,
    categoryFilter: filters.category,
  );

  final ongoingEvents = await repository.getOngoingEvents(
    typeFilter: filters.type,
    platformFilter: filters.platform,
    categoryFilter: filters.category,
  );

  final allEvents = [...upcomingEvents, ...ongoingEvents];

  final eventIdsWithEpisodes = allEvents
      .where((e) => e.id != null && e.totalEpisodes != null && e.totalEpisodes! > 0)
      .map((e) => e.id!)
      .toList();

  final Map<int, List<Episode>> allEpisodesMap = eventIdsWithEpisodes.isNotEmpty
      ? await episodeRepository.getEpisodesByMultipleEvents(eventIdsWithEpisodes)
      : {};

  Episode? findRelevantEpisode(int eventId) {
    final episodes = allEpisodesMap[eventId];
    if (episodes == null || episodes.isEmpty) return null;

    final today = DateTime(now.year, now.month, now.day);

    // PRIORYTET 1: Sprawdź czy jest jakiś odcinek DZISIAJ
    final todaysEpisodes = episodes.where((ep) {
      final epDate = DateTime(ep.airDate.year, ep.airDate.month, ep.airDate.day);
      return epDate.isAtSameMomentAs(today);
    }).toList();

    if (todaysEpisodes.isNotEmpty) {
      todaysEpisodes.sort((a, b) => a.airDate.compareTo(b.airDate));

      // Preferuj upcoming z dzisiaj
      final todaysUpcoming = todaysEpisodes.where((ep) =>
      ep.status == EpisodeStatus.upcoming
      ).toList();

      if (todaysUpcoming.isNotEmpty) {
        return todaysUpcoming.first;
      }

      // Jeśli nie ma upcoming, zwróć aired z dzisiaj (żeby pokazać w widoku Dzień)
      return todaysEpisodes.first;
    }

    // PRIORYTET 2: Najbliższy UPCOMING w przyszłości
    final futureUpcoming = episodes.where((ep) {
      return ep.status == EpisodeStatus.upcoming && ep.airDate.isAfter(now);
    }).toList();

    if (futureUpcoming.isEmpty) return null;

    futureUpcoming.sort((a, b) => a.airDate.compareTo(b.airDate));
    return futureUpcoming.first;
  }

  bool shouldShowEventInView(Event event, Episode? relevantEpisode) {
    final today = DateTime(now.year, now.month, now.day);

    final checkDate = relevantEpisode?.airDate ?? event.startDate;
    final checkDateOnly = DateTime(checkDate.year, checkDate.month, checkDate.day);

    switch (timeView) {
      case TimeView.day:
        return checkDateOnly.isAtSameMomentAs(today);

      case TimeView.week:
        final weekEnd = today.add(const Duration(days: 7));
        return !checkDateOnly.isBefore(today) && checkDateOnly.isBefore(weekEnd);

      case TimeView.month:
        final monthEnd = today.add(const Duration(days: 30));
        return !checkDateOnly.isBefore(today) && checkDateOnly.isBefore(monthEnd);
    }
  }

  final eventsWithDates = <_EventWithNextEpisode>[];

  for (var event in allEvents) {
    final relevantEpisode = event.id != null
        ? findRelevantEpisode(event.id!)
        : null;

    if (shouldShowEventInView(event, relevantEpisode)) {
      eventsWithDates.add(_EventWithNextEpisode(
        event,
        relevantEpisode?.airDate ?? event.startDate,
      ));
    }
  }

  // ✅ POPRAWIONE SORTOWANIE:
  // 1. Aired z dzisiaj → NA KOŃCU
  // 2. Upcoming → sortowane od najbliższych
  eventsWithDates.sort((a, b) {
    final dateA = a.nextEpisodeDate ?? a.event.startDate;
    final dateB = b.nextEpisodeDate ?? b.event.startDate;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Sprawdź czy odcinki są z dzisiaj I ich godzina już minęła
    final dateAOnly = DateTime(dateA.year, dateA.month, dateA.day);
    final dateBOnly = DateTime(dateB.year, dateB.month, dateB.day);

    final isATodayAndPast = dateAOnly.isAtSameMomentAs(today) && dateA.isBefore(now);
    final isBTodayAndPast = dateBOnly.isAtSameMomentAs(today) && dateB.isBefore(now);

    // REGUŁA 1: Jeśli A jest aired z dzisiaj, a B nie → B jest wyżej
    if (isATodayAndPast && !isBTodayAndPast) {
      return 1; // A idzie w dół (na koniec)
    }

    // REGUŁA 2: Jeśli B jest aired z dzisiaj, a A nie → A jest wyżej
    if (isBTodayAndPast && !isATodayAndPast) {
      return -1; // B idzie w dół (na koniec)
    }

    // REGUŁA 3: Jeśli obydwa są aired z dzisiaj LUB obydwa są upcoming
    // → sortuj normalnie po dacie (najbliższe pierwsze)
    return dateA.compareTo(dateB);
  });

  return eventsWithDates.map((e) => e.event).toList();
});

final upcomingEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  ref.watch(eventsRefreshTriggerProvider);
  final repository = ref.watch(eventRepositoryProvider);
  final filters = ref.watch(currentFiltersProvider);

  return await repository.getUpcomingEvents(
    typeFilter: filters.type,
    platformFilter: filters.platform,
    categoryFilter: filters.category,
  );
});

final ongoingEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  ref.watch(eventsRefreshTriggerProvider);
  final repository = ref.watch(eventRepositoryProvider);
  final filters = ref.watch(currentFiltersProvider);

  return await repository.getOngoingEvents(
    typeFilter: filters.type,
    platformFilter: filters.platform,
    categoryFilter: filters.category,
  );
});

final archivedEventsProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  ref.watch(eventsRefreshTriggerProvider);
  final repository = ref.watch(eventRepositoryProvider);
  final filters = ref.watch(currentFiltersProvider);

  return await repository.getArchivedEvents(
    typeFilter: filters.type,
    platformFilter: filters.platform,
    categoryFilter: filters.category,
    minRating: filters.minRating,
  );
});

final eventDetailProvider = FutureProvider.autoDispose.family<Event?, int>((ref, id) async {
  ref.watch(eventsRefreshTriggerProvider);
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getEventById(id);
});

final platformsListProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getAllPlatforms();
});

final categoriesListProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getAllCategories();
});

final episodeLocalDataSourceProvider = Provider<EpisodeLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return EpisodeLocalDataSource(dbHelper);
});

final episodeRepositoryProvider = Provider<EpisodeRepository>((ref) {
  final localDataSource = ref.watch(episodeLocalDataSourceProvider);
  return EpisodeRepositoryImpl(localDataSource);
});

final episodesByEventProvider = FutureProvider.autoDispose.family<List<Episode>, int>((ref, eventId) async {
  ref.watch(eventsRefreshTriggerProvider);
  final repository = ref.watch(episodeRepositoryProvider);
  return await repository.getEpisodesByEvent(eventId);
});

final completedEventsProvider = Provider<List<Event>>((ref) {
  throw UnimplementedError('completedEventsProvider must be overridden in main.dart');
});