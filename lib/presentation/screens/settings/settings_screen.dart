import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../../generated/l10n.dart';
import '../../providers/providers.dart';
import '../../providers/locale_provider.dart';
import '../../../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settingsTitle),
      ),
      body: ListView(
        children: [
          // JĘZYK
          _buildSection(
            context,
            title: S.of(context).language,
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFFE91E63)),
                title: Text(S.of(context).language),
                subtitle: Text(
                  currentLocale.languageCode == 'pl'
                      ? S.of(context).languagePolish
                      : S.of(context).languageEnglish,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguagePicker(context, ref),
              ),
            ],
          ),

          // POWIADOMIENIA
          _buildSection(
            context,
            title: S.of(context).notifications,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications, color: Color(0xFF2196F3)),
                title: Text(S.of(context).notifications),
                subtitle: Text(
                  settings.globalNotificationsEnabled
                      ? S.of(context).notificationsEnabled
                      : S.of(context).notificationsDisabled,
                ),
                value: settings.globalNotificationsEnabled,
                onChanged: (value) {
                  ref.read(settingsProvider.notifier).setGlobalNotifications(value);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time, color: Color(0xFF9C27B0)),
                title: Text(currentLocale.languageCode == 'pl'
                    ? 'Domyślny czas powiadomienia'
                    : 'Default notification time'),
                subtitle: Text(_formatNotificationTime(
                  settings.defaultNotificationMinutes,
                  currentLocale.languageCode,
                )),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showNotificationTimePicker(context, ref, settings),
              ),
            ],
          ),

          // WIDOK DOMYŚLNY
          _buildSection(
            context,
            title: currentLocale.languageCode == 'pl'
                ? 'Widok domyślny'
                : 'Default view',
            children: [
              ListTile(
                leading: const Icon(Icons.view_day, color: Color(0xFF4CAF50)),
                title: Text(currentLocale.languageCode == 'pl'
                    ? 'Domyślny przedział czasu'
                    : 'Default time view'),
                subtitle: Text(settings.defaultTimeView.displayName),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showTimeViewPicker(context, ref, settings),
              ),
            ],
          ),

          // ZARZĄDZANIE DANYMI
          _buildSection(
            context,
            title: currentLocale.languageCode == 'pl'
                ? 'Zarządzanie danymi'
                : 'Data management',
            children: [
              ListTile(
                leading: const Icon(Icons.refresh, color: Colors.orange),
                title: Text(currentLocale.languageCode == 'pl'
                    ? 'Przebuduj wszystkie odcinki'
                    : 'Rebuild all episodes'),
                subtitle: Text(currentLocale.languageCode == 'pl'
                    ? 'Usuń i wygeneruj ponownie z poprawnymi godzinami'
                    : 'Delete and regenerate with correct times'),
                onTap: () => _showRebuildEpisodesDialog(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(currentLocale.languageCode == 'pl'
                    ? 'Wyczyść całą bazę danych'
                    : 'Clear entire database'),
                subtitle: Text(currentLocale.languageCode == 'pl'
                    ? 'Usuń wszystkie wydarzenia (nieodwracalne)'
                    : 'Delete all events (irreversible)'),
                onTap: () => _showClearDatabaseDialog(context, ref),
              ),
            ],
          ),

          // O APLIKACJI
          _buildSection(
            context,
            title: currentLocale.languageCode == 'pl'
                ? 'O aplikacji'
                : 'About',
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Color(0xFF607D8B)),
                title: Text(currentLocale.languageCode == 'pl'
                    ? 'Wersja aplikacji'
                    : 'Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.code, color: Color(0xFF795548)),
                title: Text(currentLocale.languageCode == 'pl'
                    ? 'Informacje'
                    : 'Information'),
                subtitle: Text(currentLocale.languageCode == 'pl'
                    ? 'NextDrop - Śledź swoje ulubione serie i programy'
                    : 'NextDrop - Track your favorite shows and programs'),
                trailing: const Icon(Icons.info_outline),
                onTap: () => _showAboutDialog(context, currentLocale.languageCode),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<Widget> children,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE91E63),
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  String _formatNotificationTime(int minutes, String lang) {
    if (lang == 'pl') {
      if (minutes < 60) {
        return '$minutes minut przed';
      } else if (minutes == 60) {
        return '1 godzina przed';
      } else if (minutes < 1440) {
        final hours = minutes ~/ 60;
        return '$hours ${hours == 1 ? 'godzina' : 'godzin'} przed';
      } else {
        final days = minutes ~/ 1440;
        return '$days ${days == 1 ? 'dzień' : 'dni'} przed';
      }
    } else {
      if (minutes < 60) {
        return '$minutes minutes before';
      } else if (minutes < 1440) {
        final hours = minutes ~/ 60;
        return '$hours ${hours == 1 ? 'hour' : 'hours'} before';
      } else {
        final days = minutes ~/ 1440;
        return '$days ${days == 1 ? 'day' : 'days'} before';
      }
    }
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final currentLocale = ref.read(localeProvider);
    final lang = currentLocale.languageCode;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.language, color: Color(0xFFE91E63)),
            const SizedBox(width: 12),
            Text(
              S.of(context).language,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              title: '🇵🇱 Polski',
              value: 'pl',
              groupValue: currentLocale.languageCode,
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              context,
              title: '🇬🇧 English',
              value: 'en',
              groupValue: currentLocale.languageCode,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );

    if (result != null && result != currentLocale.languageCode) {
      await ref.read(localeProvider.notifier).setLocale(Locale(result));

      if (context.mounted) {
        // ✅ DODANE - Restart całej aplikacji
        RestartWidget.restartApp(context);

        // Pokaż snackbar po restarcie
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result == 'pl'
                      ? 'Język zmieniony na Polski 🇵🇱'
                      : 'Language changed to English 🇬🇧',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });
      }
    }
  }

  Widget _buildLanguageOption(
      BuildContext context, {
        required String title,
        required String value,
        required String groupValue,
      }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE91E63).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE91E63)
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotificationTimePicker(
      BuildContext context,
      WidgetRef ref,
      AppSettings settings,
      ) async {
    final lang = ref.read(localeProvider).languageCode;

    final options = lang == 'pl'
        ? [
      {'label': '15 minut przed', 'value': 15},
      {'label': '30 minut przed', 'value': 30},
      {'label': '1 godzina przed', 'value': 60},
      {'label': '2 godziny przed', 'value': 120},
      {'label': '1 dzień przed', 'value': 1440},
      {'label': '2 dni przed', 'value': 2880},
    ]
        : [
      {'label': '15 minutes before', 'value': 15},
      {'label': '30 minutes before', 'value': 30},
      {'label': '1 hour before', 'value': 60},
      {'label': '2 hours before', 'value': 120},
      {'label': '1 day before', 'value': 1440},
      {'label': '2 days before', 'value': 2880},
    ];

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          lang == 'pl' ? 'Czas powiadomienia' : 'Notification time',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final isSelected = settings.defaultNotificationMinutes == option['value'];
            return RadioListTile<int>(
              title: Text(
                option['label'] as String,
                style: const TextStyle(color: Colors.white),
              ),
              value: option['value'] as int,
              groupValue: settings.defaultNotificationMinutes,
              selected: isSelected,
              activeColor: const Color(0xFF2196F3),
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(settingsProvider.notifier).setDefaultNotificationMinutes(result);
    }
  }

  Future<void> _showTimeViewPicker(
      BuildContext context,
      WidgetRef ref,
      AppSettings settings,
      ) async {
    final lang = ref.read(localeProvider).languageCode;

    final result = await showDialog<TimeView>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          lang == 'pl' ? 'Domyślny przedział czasu' : 'Default time view',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TimeView.values.map((timeView) {
            final isSelected = settings.defaultTimeView == timeView;
            return RadioListTile<TimeView>(
              title: Text(
                timeView.displayName,
                style: const TextStyle(color: Colors.white),
              ),
              value: timeView,
              groupValue: settings.defaultTimeView,
              selected: isSelected,
              activeColor: const Color(0xFF4CAF50),
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(settingsProvider.notifier).setDefaultTimeView(result);
    }
  }

  Future<void> _showRebuildEpisodesDialog(BuildContext context, WidgetRef ref) async {
    final lang = ref.read(localeProvider).languageCode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          lang == 'pl' ? 'Przebudować odcinki?' : 'Rebuild episodes?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          lang == 'pl'
              ? 'Czy chcesz przebudować wszystkie odcinki?\n\n'
              'To usunie WSZYSTKIE obecne odcinki i wygeneruje je od nowa '
              'z poprawnymi godzinami na podstawie ustawień wydarzeń.\n\n'
              '⚠️ Przełożone odcinki zostaną utracone!'
              : 'Do you want to rebuild all episodes?\n\n'
              'This will delete ALL existing episodes and regenerate them '
              'with correct times based on event settings.\n\n'
              '⚠️ Postponed episodes will be lost!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text(lang == 'pl' ? 'Przebuduj' : 'Rebuild'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1a1f3a),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFE91E63)),
              const SizedBox(height: 16),
              Text(
                lang == 'pl'
                    ? 'Przebudowywanie odcinków...'
                    : 'Rebuilding episodes...',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

      final eventRepo = ref.read(eventRepositoryProvider);
      final episodeRepo = ref.read(episodeRepositoryProvider);

      final allEvents = await eventRepo.getAllEvents();

      int rebuiltCount = 0;
      int skippedCount = 0;

      for (var event in allEvents) {
        if (event.totalEpisodes == null || event.totalEpisodes! <= 0) {
          skippedCount++;
          continue;
        }

        int intervalDays = 7;
        switch (event.recurrence) {
          case Recurrence.daily:
            intervalDays = 1;
            break;
          case Recurrence.weekly:
            intervalDays = 7;
            break;
          case Recurrence.biweekly:
            intervalDays = 14;
            break;
          case Recurrence.monthly:
            intervalDays = 30;
            break;
          case Recurrence.custom:
            intervalDays = event.recurrenceInterval ?? 7;
            break;
          case Recurrence.batch:
            intervalDays = event.recurrenceInterval ?? 7;
            break;
          case Recurrence.once:
            intervalDays = 0;
            break;
        }

        await episodeRepo.generateEpisodes(
          event.id!,
          event.startDate,
          event.totalEpisodes!,
          intervalDays,
          event.startTime,
        );

        rebuiltCount++;
      }

      if (context.mounted) {
        Navigator.pop(context);
      }

      refreshAllEvents(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'pl'
                  ? '✓ Przebudowano odcinki dla $rebuiltCount wydarzeń\nPominięto: $skippedCount bez odcinków'
                  : '✓ Rebuilt episodes for $rebuiltCount events\nSkipped: $skippedCount without episodes',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'pl'
                  ? '✗ Błąd podczas przebudowy: $e'
                  : '✗ Error during rebuild: $e',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showClearDatabaseDialog(BuildContext context, WidgetRef ref) async {
    final lang = ref.read(localeProvider).languageCode;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          lang == 'pl' ? 'Wyczyścić bazę danych' : 'Clear database',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          lang == 'pl'
              ? 'Czy na pewno chcesz usunąć wszystkie wydarzenia? '
              'Ta operacja jest nieodwracalna!'
              : 'Are you sure you want to delete all events? '
              'This operation is irreversible!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(lang == 'pl' ? 'Usuń wszystko' : 'Delete all'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dbHelper = DatabaseHelper.instance;
        await dbHelper.deleteDatabase();

        refreshAllEvents(ref);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'pl'
                    ? 'Baza danych została wyczyszczona'
                    : 'Database has been cleared',
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                lang == 'pl'
                    ? 'Błąd podczas czyszczenia bazy: $e'
                    : 'Error clearing database: $e',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showAboutDialog(BuildContext context, String lang) {
    showAboutDialog(
      context: context,
      applicationName: 'NextDrop',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.event, size: 48, color: Color(0xFFE91E63)),
      children: [
        Text(
          lang == 'pl'
              ? 'Aplikacja do śledzenia wydarzeń cyklicznych takich jak '
              'seriale, anime, podcasty i programy telewizyjne.'
              : 'Application for tracking recurring events such as '
              'series, anime, podcasts and TV shows.',
        ),
      ],
    );
  }
}