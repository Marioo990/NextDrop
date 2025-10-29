import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/enums.dart';

class SettingsRepository {
  final SharedPreferences prefs;

  SettingsRepository(this.prefs);

  // Global Notifications
  bool getGlobalNotifications() {
    return prefs.getBool(AppConstants.keyGlobalNotifications) ?? true;
  }

  Future<void> setGlobalNotifications(bool value) async {
    await prefs.setBool(AppConstants.keyGlobalNotifications, value);
  }

  // Default Notification Minutes
  int getDefaultNotificationMinutes() {
    return prefs.getInt(AppConstants.keyDefaultNotificationMinutes) ??
        AppConstants.defaultNotificationMinutes;
  }

  Future<void> setDefaultNotificationMinutes(int minutes) async {
    await prefs.setInt(AppConstants.keyDefaultNotificationMinutes, minutes);
  }

  // Default Time View
  TimeView getDefaultTimeView() {
    final value = prefs.getString(AppConstants.keyDefaultTimeView) ??
        AppConstants.defaultTimeView;
    return TimeView.fromString(value);
  }

  Future<void> setDefaultTimeView(TimeView timeView) async {
    await prefs.setString(AppConstants.keyDefaultTimeView, timeView.value);
  }
}