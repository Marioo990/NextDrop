// NOWY PLIK: lib/core/services/backup_service.dart
// System automatycznych kopii zapasowych bazy danych

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

class BackupService {
  static const int maxBackups = 5;
  static const Duration backupInterval = Duration(days: 1);

  /// Tworzy backup bazy danych
  static Future<File?> createBackup() async {
    try {
      debugPrint('🔄 Starting database backup...');

      // Pobierz ścieżkę do bazy danych
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, AppConstants.databaseName));

      // Sprawdź czy baza istnieje
      if (!await dbFile.exists()) {
        debugPrint('⚠️ Database file does not exist');
        return null;
      }

      // Utwórz folder backupów
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(join(appDir.path, 'backups'));

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
        debugPrint('📁 Created backup directory: ${backupDir.path}');
      }

      // Nazwa pliku z timestampem
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final backupFile = File(join(backupDir.path, 'backup_$timestamp.db'));

      // Kopiuj bazę danych
      await dbFile.copy(backupFile.path);

      final sizeInKb = await backupFile.length() / 1024;
      debugPrint('✅ Backup created successfully: ${backupFile.path}');
      debugPrint('📊 Backup size: ${sizeInKb.toStringAsFixed(2)} KB');

      // Wyczyść stare backupy
      await _cleanOldBackups(backupDir);

      return backupFile;
    } catch (e, stackTrace) {
      debugPrint('❌ Backup failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Przywraca bazę danych z backupu
  static Future<bool> restoreBackup(File backupFile) async {
    try {
      debugPrint('🔄 Starting database restore...');

      if (!await backupFile.exists()) {
        debugPrint('❌ Backup file does not exist: ${backupFile.path}');
        return false;
      }

      // Zamknij połączenie z bazą
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, AppConstants.databaseName));

      // Sprawdź czy backup jest poprawny
      if (!await _isValidBackup(backupFile)) {
        debugPrint('❌ Backup file is not valid');
        return false;
      }

      // Utwórz backup obecnej bazy (na wszelki wypadek)
      if (await dbFile.exists()) {
        final emergencyBackup = File('${dbFile.path}.emergency');
        await dbFile.copy(emergencyBackup.path);
        debugPrint('💾 Created emergency backup');
      }

      // Przywróć z backupu
      await backupFile.copy(dbFile.path);

      debugPrint('✅ Database restored successfully from: ${backupFile.path}');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Restore failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Sprawdza czy backup jest poprawny (czy da się otworzyć jako baza SQLite)
  static Future<bool> _isValidBackup(File backupFile) async {
    try {
      final db = await openDatabase(backupFile.path, readOnly: true);

      // Sprawdź czy są wymagane tabele
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'"
      );

      final tableNames = tables.map((t) => t['name'] as String).toList();
      final hasEventsTable = tableNames.contains(AppConstants.eventsTable);
      final hasEpisodesTable = tableNames.contains(AppConstants.upcomingEpisodesTable);

      await db.close();

      return hasEventsTable && hasEpisodesTable;
    } catch (e) {
      debugPrint('⚠️ Backup validation failed: $e');
      return false;
    }
  }

  /// Usuwa stare backupy, zachowując tylko najnowsze
  static Future<void> _cleanOldBackups(Directory backupDir) async {
    try {
      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();

      if (files.length <= maxBackups) {
        debugPrint('ℹ️ ${files.length} backups, no cleanup needed');
        return;
      }

      // Sortuj według daty modyfikacji (najnowsze pierwsze)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Usuń nadmiarowe backupy
      int deletedCount = 0;
      for (var i = maxBackups; i < files.length; i++) {
        await files[i].delete();
        deletedCount++;
        debugPrint('🗑️ Deleted old backup: ${basename(files[i].path)}');
      }

      if (deletedCount > 0) {
        debugPrint('✅ Cleanup complete: deleted $deletedCount old backups');
      }
    } catch (e) {
      debugPrint('⚠️ Cleanup failed: $e');
    }
  }

  /// Zwraca listę dostępnych backupów
  static Future<List<BackupInfo>> getAvailableBackups() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory(join(appDir.path, 'backups'));

      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.db'))
          .cast<File>()
          .toList();

      // Sortuj od najnowszych
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      final backups = <BackupInfo>[];
      for (var file in files) {
        final size = await file.length();
        final modified = await file.lastModified();

        backups.add(BackupInfo(
          file: file,
          fileName: basename(file.path),
          sizeBytes: size,
          createdAt: modified,
        ));
      }

      return backups;
    } catch (e) {
      debugPrint('❌ Failed to get backups list: $e');
      return [];
    }
  }

  /// Sprawdza czy potrzebny jest automatyczny backup
  static Future<bool> shouldCreateAutoBackup() async {
    try {
      final backups = await getAvailableBackups();

      if (backups.isEmpty) {
        return true; // Brak backupów, utwórz pierwszy
      }

      final lastBackup = backups.first;
      final timeSinceLastBackup = DateTime.now().difference(lastBackup.createdAt);

      return timeSinceLastBackup > backupInterval;
    } catch (e) {
      debugPrint('⚠️ Failed to check backup status: $e');
      return false;
    }
  }

  /// Automatyczny backup (wywołaj przy starcie aplikacji)
  static Future<void> autoBackup() async {
    try {
      if (await shouldCreateAutoBackup()) {
        debugPrint('📅 Auto-backup triggered');
        await createBackup();
      } else {
        debugPrint('ℹ️ Auto-backup not needed yet');
      }
    } catch (e) {
      debugPrint('⚠️ Auto-backup check failed: $e');
    }
  }

  /// Eksportuje backup do wybranej lokalizacji (dla użytkownika)
  static Future<bool> exportBackup(File backupFile, String destinationPath) async {
    try {
      final destination = File(destinationPath);
      await backupFile.copy(destination.path);
      debugPrint('✅ Backup exported to: $destinationPath');
      return true;
    } catch (e) {
      debugPrint('❌ Export failed: $e');
      return false;
    }
  }
}

/// Informacje o backupie
class BackupInfo {
  final File file;
  final String fileName;
  final int sizeBytes;
  final DateTime createdAt;

  BackupInfo({
    required this.file,
    required this.fileName,
    required this.sizeBytes,
    required this.createdAt,
  });

  String get sizeFormatted {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String get dateFormatted {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

// ========================================
// JAK UŻYĆ W MAIN.DART:
// ========================================
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   try {
//     // ... inicjalizacje ...
//
//     // Automatyczny backup przy starcie
//     await BackupService.autoBackup();
//
//     runApp(MyApp());
//   } catch (e) {
//     // ...
//   }
// }

// ========================================
// JAK DODAĆ DO USTAWIEŃ (settings_screen.dart):
// ========================================
//
// ListTile(
//   leading: const Icon(Icons.backup),
//   title: const Text('Kopie zapasowe'),
//   subtitle: const Text('Zarządzaj backupami bazy danych'),
//   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//   onTap: () => _showBackupDialog(context),
// ),
//
// Future<void> _showBackupDialog(BuildContext context) async {
//   final backups = await BackupService.getAvailableBackups();
//
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: const Text('Kopie zapasowe'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.add_circle),
//             title: const Text('Utwórz nowy backup'),
//             onTap: () async {
//               Navigator.pop(context);
//               final backup = await BackupService.createBackup();
//               if (backup != null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Backup utworzony')),
//                 );
//               }
//             },
//           ),
//           const Divider(),
//           if (backups.isEmpty)
//             const Padding(
//               padding: EdgeInsets.all(16),
//               child: Text('Brak dostępnych backupów'),
//             )
//           else
//             ...backups.map((backup) => ListTile(
//               title: Text(backup.fileName),
//               subtitle: Text('${backup.dateFormatted} • ${backup.sizeFormatted}'),
//               trailing: IconButton(
//                 icon: const Icon(Icons.restore),
//                 onPressed: () async {
//                   final confirm = await showDialog<bool>(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Przywróć backup'),
//                       content: const Text(
//                         'Czy na pewno chcesz przywrócić tę kopię? '
//                         'Obecne dane zostaną zastąpione.',
//                       ),
//                       actions: [
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, false),
//                           child: const Text('Anuluj'),
//                         ),
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, true),
//                           child: const Text('Przywróć'),
//                         ),
//                       ],
//                     ),
//                   );
//
//                   if (confirm == true) {
//                     final success = await BackupService.restoreBackup(backup.file);
//                     if (context.mounted) {
//                       Navigator.pop(context);
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             success
//                                 ? 'Backup przywrócony. Zrestartuj aplikację.'
//                                 : 'Błąd przywracania backupu',
//                           ),
//                         ),
//                       );
//                     }
//                   }
//                 },
//               ),
//             )),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Zamknij'),
//         ),
//       ],
//     ),
//   );
// }