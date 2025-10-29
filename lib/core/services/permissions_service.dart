import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static final PermissionsService instance = PermissionsService._internal();
  factory PermissionsService() => instance;
  PermissionsService._internal();

  Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestPhotosPermission() async {
    PermissionStatus status;

    if (await Permission.photos.isGranted) {
      return true;
    }

    status = await Permission.photos.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      if (await Permission.storage.isGranted) {
        return true;
      }
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  Future<bool> showPermissionRationale(
      BuildContext context, {
        required String title,
        required String message,
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Przejdź do ustawień'),
          ),
        ],
      ),
    ) ?? false;
  }

  // POPRAWKA: Zmieniona nazwa i prawidłowe wywołanie
  Future<bool> openSystemSettings() async {
    return await openAppSettings(); // z pakietu permission_handler
  }
}