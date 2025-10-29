import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider dla SharedPreferences
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

// StateNotifier dla języka
class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences prefs;
  static const String _localeKey = 'app_locale';

  LocaleNotifier(this.prefs) : super(_loadLocale(prefs));

  static Locale _loadLocale(SharedPreferences prefs) {
    final languageCode = prefs.getString(_localeKey) ?? 'pl';
    return Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    await prefs.setString(_localeKey, locale.languageCode);
    state = locale;
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'pl'
        ? const Locale('en')
        : const Locale('pl');
    setLocale(newLocale);
  }
}

// Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LocaleNotifier(prefs);
});