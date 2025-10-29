// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/services/notification_service.dart';
import 'core/services/permissions_service.dart';
import 'core/services/auto_archive_service.dart';
import 'core/utils/event_validator.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/event_local_datasource.dart';
import 'data/datasources/local/episode_local_datasource.dart';
import 'data/repositories/event_repository_impl.dart';
import 'data/repositories/episode_repository_impl.dart';
import 'data/repositories/settings_repository.dart';
import 'core/constants/enums.dart';
import 'domain/entities/event.dart';
import 'presentation/providers/providers.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/screens/main_navigation.dart';
import 'generated/l10n.dart';

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeDateFormatting('pl_PL', null);
    debugPrint('✓ Locale initialized');

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
    debugPrint('✓ Timezone initialized');

    final prefs = await SharedPreferences.getInstance();
    debugPrint('✓ SharedPreferences initialized');

    await NotificationService.instance.initialize();
    debugPrint('✓ NotificationService initialized');

    await NotificationService.instance.requestPermissions();
    debugPrint('✓ Notification permissions requested');

    final notificationPermission = await PermissionsService.instance.requestNotificationPermission();
    debugPrint('✓ Notification permission: $notificationPermission');

    await _updateEventStatuses();
    debugPrint('✓ Event statuses updated');

    final completedEvents = await _checkAndArchiveCompletedEvents();
    debugPrint('✓ Auto-archive check complete (${completedEvents.length} events)');

    runApp(
      RestartWidget(  // ✅ DODANE
        child: ProviderScope(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              SettingsRepository(prefs),
            ),
            completedEventsProvider.overrideWithValue(completedEvents),
            sharedPrefsProvider.overrideWithValue(prefs),
          ],
          child: const MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('✗ FATAL ERROR in main(): $e');
    debugPrint('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Błąd inicjalizacji aplikacji',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _updateEventStatuses() async {
  try {
    debugPrint('Starting event status update with validation...');

    final dbHelper = DatabaseHelper.instance;
    final dataSource = EventLocalDataSource(dbHelper);
    final repository = EventRepositoryImpl(dataSource);

    final allEvents = await repository.getAllEvents();
    debugPrint('Found ${allEvents.length} events');

    int updatedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    for (var event in allEvents) {
      try {
        if (event.status == EventStatus.archived) {
          skippedCount++;
          continue;
        }

        final suggestedStatus = EventValidator.suggestStatus(
          event.startDate,
          event.endDate,
        );

        if (suggestedStatus != event.status) {
          final updatedEvent = event.copyWith(status: suggestedStatus);
          final errors = EventValidator.validateEvent(updatedEvent);

          if (errors.isEmpty) {
            await repository.updateEvent(updatedEvent);
            updatedCount++;
            debugPrint('Updated event ${event.id}: ${event.status.value} → ${suggestedStatus.value}');
          } else {
            skippedCount++;
            debugPrint('⚠ Event ${event.id} validation failed: ${errors.keys.join(", ")}');
          }
        } else {
          skippedCount++;
        }
      } catch (e) {
        errorCount++;
        debugPrint('✗ Error updating event ${event.id}: $e');
        continue;
      }
    }

    debugPrint('✓ Updated $updatedCount event statuses');
    if (errorCount > 0) {
      debugPrint('⚠ $errorCount events had errors');
    }
  } catch (e, stackTrace) {
    debugPrint('✗ Error updating event statuses: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

Future<List<Event>> _checkAndArchiveCompletedEvents() async {
  try {
    debugPrint('🔄 Checking for completed events...');

    final dbHelper = DatabaseHelper.instance;
    final eventDataSource = EventLocalDataSource(dbHelper);
    final episodeDataSource = EpisodeLocalDataSource(dbHelper);

    final eventRepo = EventRepositoryImpl(eventDataSource);
    final episodeRepo = EpisodeRepositoryImpl(episodeDataSource);

    final autoArchiveService = AutoArchiveService(
      eventRepository: eventRepo,
      episodeRepository: episodeRepo,
    );

    final completedEvents = await autoArchiveService.checkAndArchiveCompletedEvents();

    if (completedEvents.isNotEmpty) {
      debugPrint('📦 Found ${completedEvents.length} completed events to rate');
    }

    return completedEvents;
  } catch (e, stackTrace) {
    debugPrint('❌ Error in auto-archive: $e');
    debugPrint('Stack trace: $stackTrace');
    return [];
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  int? _selectedRating;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRatingDialogsIfNeeded();
    });
  }

  Future<void> _showRatingDialogsIfNeeded() async {
    final completedEvents = ref.read(completedEventsProvider);

    if (completedEvents.isEmpty) return;

    final eventsNeedingRating = completedEvents.where((e) => e.rating == null).toList();

    if (eventsNeedingRating.isEmpty) return;

    final event = eventsNeedingRating.first;

    if (mounted) {
      await _showRatingDialog(event);
    }
  }

  Future<void> _showRatingDialog(Event event) async {
    _selectedRating = null;

    final rating = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1a1f3a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '${S.of(context).edit}: ${event.title}',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).ratingPrompt,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(10, (index) {
                  final value = index + 1;
                  final isSelected = _selectedRating == value;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedRating = value);
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (context.mounted) {
                          Navigator.pop(context, value);
                        }
                      });
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                        )
                            : null,
                        color: isSelected ? null : const Color(0xFF2a2f4a),
                        borderRadius: BorderRadius.circular(22.5),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.grey[700]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.grey[400],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
          ],
        ),
      ),
    );

    if (rating != null) {
      final updatedEvent = event.copyWith(rating: rating);
      await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);

      refreshAllEvents(ref);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).ratingAdded(rating)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'NextDrop',
      debugShowCheckedModeBanner: false,

      locale: locale,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),

        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE91E63),
          secondary: const Color(0xFF2196F3),
          tertiary: const Color(0xFF9C27B0),
          surface: const Color(0xFF1a1f3a),
          background: const Color(0xFF0A0E27),
          error: Colors.redAccent,
        ),
        useMaterial3: true,

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1a1f3a),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        cardTheme: CardThemeData(
          elevation: 8,
          color: const Color(0xFF1a1f3a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1a1f3a),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 2,
              color: Color(0xFFE91E63),
            ),
          ),
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 8,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1a1f3a),
          selectedItemColor: Color(0xFFE91E63),
          unselectedItemColor: Colors.grey,
          elevation: 16,
          type: BottomNavigationBarType.fixed,
        ),

        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFF1a1f3a),
          selectedColor: const Color(0xFFE91E63),
          disabledColor: const Color(0xFF1a1f3a).withOpacity(0.5),
          labelStyle: const TextStyle(color: Colors.white),
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),

        dividerColor: Colors.white.withOpacity(0.1),
      ),
      home: const MainNavigation(),
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 25,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: child,
      ),
    );
  }
}

class GradientFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const GradientFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(icon, size: 28),
      ),
    );
  }
}

class GradientCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const GradientCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE91E63).withOpacity(0.1),
            const Color(0xFF2196F3).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}