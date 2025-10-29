// settings_screen.dart
// 13.42 KB •410 lines
// •
// Formatting may be inconsistent from source
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/constants/enums.dart';
// import '../../providers/providers.dart';
//
// class SettingsScreen extends ConsumerWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final settings = ref.watch(settingsProvider);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ustawienia'),
//       ),
//       body: ListView(
//         children: [
//           _buildSection(
//             title: 'Powiadomienia',
//             children: [
//               SwitchListTile(
//                 title: const Text('Globalne powiadomienia'),
//                 subtitle: const Text('WÅ‚Ä…cz/wyÅ‚Ä…cz wszystkie powiadomienia'),
//                 value: settings.globalNotificationsEnabled,
//                 onChanged: (value) {
//                   ref.read(settingsProvider.notifier).setGlobalNotifications(value);
//                 },
//               ),
//               ListTile(
//                 title: const Text('DomyÅ›lny czas powiadomienia'),
//                 subtitle: Text(_formatNotificationTime(settings.defaultNotificationMinutes)),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () => _showNotificationTimePicker(context, ref, settings),
//               ),
//             ],
//           ),
//           _buildSection(
//             title: 'Widok domyÅ›lny',
//             children: [
//               ListTile(
//                 title: const Text('DomyÅ›lny przedziaÅ‚ czasu'),
//                 subtitle: Text(settings.defaultTimeView.displayName),
//                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                 onTap: () => _showTimeViewPicker(context, ref, settings),
//               ),
//             ],
//           ),
//           _buildSection(
//             title: 'ZarzÄ…dzanie danymi',
//             children: [
//               // âœ… NOWE: Przycisk do przebudowy odcinkÃ³w
//               ListTile(
//                 leading: const Icon(Icons.refresh, color: Colors.orange),
//                 title: const Text('Przebuduj wszystkie odcinki'),
//                 subtitle: const Text('UsuÅ„ i wygeneruj ponownie z poprawnymi godzinami'),
//                 onTap: () => _showRebuildEpisodesDialog(context, ref),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.delete_forever, color: Colors.red),
//                 title: const Text('WyczyÅ›Ä‡ caÅ‚Ä… bazÄ™ danych'),
//                 subtitle: const Text('UsuÅ„ wszystkie wydarzenia (nieodwracalne)'),
//                 onTap: () => _showClearDatabaseDialog(context, ref),
//               ),
//             ],
//           ),
//           _buildSection(
//             title: 'O aplikacji',
//             children: [
//               const ListTile(
//                 title: Text('Wersja aplikacji'),
//                 subtitle: Text('1.0.0'),
//               ),
//               ListTile(
//                 title: const Text('Informacje'),
//                 subtitle: const Text('NextDrop - ÅšledÅº swoje ulubione serie i programy'),
//                 trailing: const Icon(Icons.info_outline),
//                 onTap: () => _showAboutDialog(context),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSection({required String title, required List<Widget> children}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
//           child: Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.blue,
//             ),
//           ),
//         ),
//         ...children,
//         const Divider(height: 1),
//       ],
//     );
//   }
//
//   String _formatNotificationTime(int minutes) {
//     if (minutes < 60) {
//       return '$minutes minut przed';
//     } else if (minutes == 60) {
//       return '1 godzina przed';
//     } else if (minutes < 1440) {
//       final hours = minutes ~/ 60;
//       return '$hours ${hours == 1 ? 'godzina' : 'godzin'} przed';
//     } else {
//       final days = minutes ~/ 1440;
//       return '$days ${days == 1 ? 'dzieÅ„' : 'dni'} przed';
//     }
//   }
//
//   Future<void> _showNotificationTimePicker(
//       BuildContext context,
//       WidgetRef ref,
//       AppSettings settings,
//       ) async {
//     final options = [
//       {'label': '15 minut przed', 'value': 15},
//       {'label': '30 minut przed', 'value': 30},
//       {'label': '1 godzina przed', 'value': 60},
//       {'label': '2 godziny przed', 'value': 120},
//       {'label': '1 dzieÅ„ przed', 'value': 1440},
//       {'label': '2 dni przed', 'value': 2880},
//     ];
//
//     final result = await showDialog<int>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Czas powiadomienia'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: options.map((option) {
//             final isSelected = settings.defaultNotificationMinutes == option['value'];
//             return RadioListTile<int>(
//               title: Text(option['label'] as String),
//               value: option['value'] as int,
//               groupValue: settings.defaultNotificationMinutes,
//               selected: isSelected,
//               onChanged: (value) => Navigator.pop(context, value),
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Anuluj'),
//           ),
//         ],
//       ),
//     );
//
//     if (result != null) {
//       await ref.read(settingsProvider.notifier).setDefaultNotificationMinutes(result);
//     }
//   }
//
//   Future<void> _showTimeViewPicker(
//       BuildContext context,
//       WidgetRef ref,
//       AppSettings settings,
//       ) async {
//     final result = await showDialog<TimeView>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('DomyÅ›lny przedziaÅ‚ czasu'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: TimeView.values.map((timeView) {
//             final isSelected = settings.defaultTimeView == timeView;
//             return RadioListTile<TimeView>(
//               title: Text(timeView.displayName),
//               value: timeView,
//               groupValue: settings.defaultTimeView,
//               selected: isSelected,
//               onChanged: (value) => Navigator.pop(context, value),
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Anuluj'),
//           ),
//         ],
//       ),
//     );
//
//     if (result != null) {
//       await ref.read(settingsProvider.notifier).setDefaultTimeView(result);
//     }
//   }
//
//   // âœ… NOWA METODA: Przebudowa wszystkich odcinkÃ³w
//   Future<void> _showRebuildEpisodesDialog(BuildContext context, WidgetRef ref) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('PrzebudowaÄ‡ odcinki?'),
//         content: const Text(
//           'Czy chcesz przebudowaÄ‡ wszystkie odcinki?\n\n'
//               'To usunie WSZYSTKIE obecne odcinki i wygeneruje je od nowa '
//               'z poprawnymi godzinami na podstawie ustawieÅ„ wydarzeÅ„.\n\n'
//               'âš ï¸ PrzeÅ‚oÅ¼one odcinki zostanÄ… utracone!',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Anuluj'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.orange),
//             child: const Text('Przebuduj'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm != true) return;
//
//     try {
//       // PokaÅ¼ progress indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const AlertDialog(
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Przebudowywanie odcinkÃ³w...'),
//             ],
//           ),
//         ),
//       );
//
//       final eventRepo = ref.read(eventRepositoryProvider);
//       final episodeRepo = ref.read(episodeRepositoryProvider);
//
//       // Pobierz wszystkie wydarzenia
//       final allEvents = await eventRepo.getAllEvents();
//
//       int rebuiltCount = 0;
//       int skippedCount = 0;
//
//       for (var event in allEvents) {
//         // PomiÅ„ wydarzenia bez odcinkÃ³w
//         if (event.totalEpisodes == null || event.totalEpisodes! <= 0) {
//           skippedCount++;
//           continue;
//         }
//
//         // Oblicz interwaÅ‚
//         int intervalDays = 7;
//         switch (event.recurrence) {
//           case Recurrence.daily:
//             intervalDays = 1;
//             break;
//           case Recurrence.weekly:
//             intervalDays = 7;
//             break;
//           case Recurrence.biweekly:
//             intervalDays = 14;
//             break;
//           case Recurrence.monthly:
//             intervalDays = 30;
//             break;
//           case Recurrence.custom:
//             intervalDays = event.recurrenceInterval ?? 7;
//             break;
//           case Recurrence.batch:
//             intervalDays = event.recurrenceInterval ?? 7;
//             break;
//           case Recurrence.once:
//             intervalDays = 0;
//             break;
//         }
//
//         // Przebuduj odcinki Z GODZINÄ„
//         await episodeRepo.generateEpisodes(
//           event.id!,
//           event.startDate,
//           event.totalEpisodes!,
//           intervalDays,
//           event.startTime, // âœ… PrzekaÅ¼ godzinÄ™!
//         );
//
//         rebuiltCount++;
//       }
//
//       // Zamknij progress indicator
//       if (context.mounted) {
//         Navigator.pop(context);
//       }
//
//       // OdÅ›wieÅ¼ widok
//       ref.invalidate(homeEventsProvider);
//       ref.invalidate(upcomingEventsProvider);
//       ref.invalidate(ongoingEventsProvider);
//       ref.invalidate(archivedEventsProvider);
//
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'âœ… Przebudowano odcinki dla $rebuiltCount wydarzeÅ„\n'
//                   'PominiÄ™to: $skippedCount bez odcinkÃ³w',
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 4),
//           ),
//         );
//       }
//     } catch (e, stackTrace) {
//       // Zamknij progress indicator w razie bÅ‚Ä™du
//       if (context.mounted) {
//         Navigator.pop(context);
//
//         // PokaÅ¼ szczegÃ³Å‚y bÅ‚Ä™du
//         debugPrint('âŒ BÅ‚Ä…d podczas przebudowy odcinkÃ³w: $e');
//         debugPrint('Stack trace: $stackTrace');
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('âŒ BÅ‚Ä…d podczas przebudowy: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     }
//   }
//
//   Future<void> _showClearDatabaseDialog(BuildContext context, WidgetRef ref) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('WyczyÅ›Ä‡ bazÄ™ danych'),
//         content: const Text(
//           'Czy na pewno chcesz usunÄ…Ä‡ wszystkie wydarzenia? '
//               'Ta operacja jest nieodwracalna!',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Anuluj'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('UsuÅ„ wszystko'),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       try {
//         final dbHelper = ref.read(databaseHelperProvider);
//         await dbHelper.deleteDatabase();
//
//         ref.invalidate(homeEventsProvider);
//         ref.invalidate(upcomingEventsProvider);
//         ref.invalidate(ongoingEventsProvider);
//         ref.invalidate(archivedEventsProvider);
//
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Baza danych zostaÅ‚a wyczyszczona')),
//           );
//         }
//       } catch (e) {
//         if (context.mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('BÅ‚Ä…d podczas czyszczenia bazy: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }
//
//   void _showAboutDialog(BuildContext context) {
//     showAboutDialog(
//       context: context,
//       applicationName: 'NextDrop',
//       applicationVersion: '1.0.0',
//       applicationIcon: const Icon(Icons.event, size: 48),
//       children: [
//         const Text(
//           'Aplikacja do Å›ledzenia wydarzeÅ„ cyklicznych takich jak '
//               'seriale, anime, podcasty i programy telewizyjne.',
//         ),
//       ],
//     );
//   }
// }