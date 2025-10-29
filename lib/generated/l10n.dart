// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `NextDrop`
  String get appTitle {
    return Intl.message(
      'NextDrop',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `Moje wydarzenia`
  String get homeTitle {
    return Intl.message(
      'Moje wydarzenia',
      name: 'homeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Przyszłe`
  String get upcomingTitle {
    return Intl.message(
      'Przyszłe',
      name: 'upcomingTitle',
      desc: '',
      args: [],
    );
  }

  /// `W trakcie emisji`
  String get currentTitle {
    return Intl.message(
      'W trakcie emisji',
      name: 'currentTitle',
      desc: '',
      args: [],
    );
  }

  /// `Archiwum`
  String get archivedTitle {
    return Intl.message(
      'Archiwum',
      name: 'archivedTitle',
      desc: '',
      args: [],
    );
  }

  /// `Ustawienia`
  String get settingsTitle {
    return Intl.message(
      'Ustawienia',
      name: 'settingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Dodaj wydarzenie`
  String get addEvent {
    return Intl.message(
      'Dodaj wydarzenie',
      name: 'addEvent',
      desc: '',
      args: [],
    );
  }

  /// `Edytuj wydarzenie`
  String get editEvent {
    return Intl.message(
      'Edytuj wydarzenie',
      name: 'editEvent',
      desc: '',
      args: [],
    );
  }

  /// `Usuń wydarzenie`
  String get deleteEvent {
    return Intl.message(
      'Usuń wydarzenie',
      name: 'deleteEvent',
      desc: '',
      args: [],
    );
  }

  /// `Zarchiwizuj`
  String get archiveEvent {
    return Intl.message(
      'Zarchiwizuj',
      name: 'archiveEvent',
      desc: '',
      args: [],
    );
  }

  /// `Tytuł`
  String get eventTitle {
    return Intl.message(
      'Tytuł',
      name: 'eventTitle',
      desc: '',
      args: [],
    );
  }

  /// `Opis`
  String get eventDescription {
    return Intl.message(
      'Opis',
      name: 'eventDescription',
      desc: '',
      args: [],
    );
  }

  /// `Platforma`
  String get eventPlatform {
    return Intl.message(
      'Platforma',
      name: 'eventPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Kategoria`
  String get eventCategory {
    return Intl.message(
      'Kategoria',
      name: 'eventCategory',
      desc: '',
      args: [],
    );
  }

  /// `Typ`
  String get eventType {
    return Intl.message(
      'Typ',
      name: 'eventType',
      desc: '',
      args: [],
    );
  }

  /// `Serial`
  String get series {
    return Intl.message(
      'Serial',
      name: 'series',
      desc: '',
      args: [],
    );
  }

  /// `Anime`
  String get anime {
    return Intl.message(
      'Anime',
      name: 'anime',
      desc: '',
      args: [],
    );
  }

  /// `Podcast`
  String get podcast {
    return Intl.message(
      'Podcast',
      name: 'podcast',
      desc: '',
      args: [],
    );
  }

  /// `Program TV`
  String get tvShow {
    return Intl.message(
      'Program TV',
      name: 'tvShow',
      desc: '',
      args: [],
    );
  }

  /// `Film`
  String get movie {
    return Intl.message(
      'Film',
      name: 'movie',
      desc: '',
      args: [],
    );
  }

  /// `Przyszłe`
  String get upcoming {
    return Intl.message(
      'Przyszłe',
      name: 'upcoming',
      desc: '',
      args: [],
    );
  }

  /// `W trakcie`
  String get ongoing {
    return Intl.message(
      'W trakcie',
      name: 'ongoing',
      desc: '',
      args: [],
    );
  }

  /// `Zakończone`
  String get archived {
    return Intl.message(
      'Zakończone',
      name: 'archived',
      desc: '',
      args: [],
    );
  }

  /// `Powiadomienia`
  String get notifications {
    return Intl.message(
      'Powiadomienia',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Powiadomienia włączone`
  String get notificationsEnabled {
    return Intl.message(
      'Powiadomienia włączone',
      name: 'notificationsEnabled',
      desc: '',
      args: [],
    );
  }

  /// `Powiadomienia wyłączone`
  String get notificationsDisabled {
    return Intl.message(
      'Powiadomienia wyłączone',
      name: 'notificationsDisabled',
      desc: '',
      args: [],
    );
  }

  /// `Zapisz`
  String get save {
    return Intl.message(
      'Zapisz',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Anuluj`
  String get cancel {
    return Intl.message(
      'Anuluj',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Usuń`
  String get delete {
    return Intl.message(
      'Usuń',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Edytuj`
  String get edit {
    return Intl.message(
      'Edytuj',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Czy na pewno chcesz usunąć to wydarzenie?`
  String get confirmDelete {
    return Intl.message(
      'Czy na pewno chcesz usunąć to wydarzenie?',
      name: 'confirmDelete',
      desc: '',
      args: [],
    );
  }

  /// `Wydarzenie zostało usunięte`
  String get eventDeleted {
    return Intl.message(
      'Wydarzenie zostało usunięte',
      name: 'eventDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Wydarzenie zostało zapisane`
  String get eventSaved {
    return Intl.message(
      'Wydarzenie zostało zapisane',
      name: 'eventSaved',
      desc: '',
      args: [],
    );
  }

  /// `Język`
  String get language {
    return Intl.message(
      'Język',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Polski`
  String get languagePolish {
    return Intl.message(
      'Polski',
      name: 'languagePolish',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get languageEnglish {
    return Intl.message(
      'English',
      name: 'languageEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Odcinki`
  String get episodes {
    return Intl.message(
      'Odcinki',
      name: 'episodes',
      desc: '',
      args: [],
    );
  }

  /// `Odcinek`
  String get episode {
    return Intl.message(
      'Odcinek',
      name: 'episode',
      desc: '',
      args: [],
    );
  }

  /// `Odcinek {number}`
  String episodeNumber(int number) {
    return Intl.message(
      'Odcinek $number',
      name: 'episodeNumber',
      desc: '',
      args: [number],
    );
  }

  /// `za {time}`
  String timeIn(String time) {
    return Intl.message(
      'za $time',
      name: 'timeIn',
      desc: '',
      args: [time],
    );
  }

  /// `Oceń wydarzenie (1-10):`
  String get ratingPrompt {
    return Intl.message(
      'Oceń wydarzenie (1-10):',
      name: 'ratingPrompt',
      desc: '',
      args: [],
    );
  }

  /// `Ocena dodana: {rating}/10`
  String ratingAdded(int rating) {
    return Intl.message(
      'Ocena dodana: $rating/10',
      name: 'ratingAdded',
      desc: '',
      args: [rating],
    );
  }

  /// `Domyślny czas powiadomienia`
  String get defaultNotificationTime {
    return Intl.message(
      'Domyślny czas powiadomienia',
      name: 'defaultNotificationTime',
      desc: '',
      args: [],
    );
  }

  /// `Domyślny przedział czasu`
  String get defaultTimeView {
    return Intl.message(
      'Domyślny przedział czasu',
      name: 'defaultTimeView',
      desc: '',
      args: [],
    );
  }

  /// `Zarządzanie danymi`
  String get dataManagement {
    return Intl.message(
      'Zarządzanie danymi',
      name: 'dataManagement',
      desc: '',
      args: [],
    );
  }

  /// `Przebuduj wszystkie odcinki`
  String get rebuildAllEpisodes {
    return Intl.message(
      'Przebuduj wszystkie odcinki',
      name: 'rebuildAllEpisodes',
      desc: '',
      args: [],
    );
  }

  /// `Usuń i wygeneruj ponownie z poprawnymi godzinami`
  String get rebuildDescription {
    return Intl.message(
      'Usuń i wygeneruj ponownie z poprawnymi godzinami',
      name: 'rebuildDescription',
      desc: '',
      args: [],
    );
  }

  /// `Wyczyść całą bazę danych`
  String get clearDatabase {
    return Intl.message(
      'Wyczyść całą bazę danych',
      name: 'clearDatabase',
      desc: '',
      args: [],
    );
  }

  /// `Usuń wszystkie wydarzenia (nieodwracalne)`
  String get clearDatabaseDescription {
    return Intl.message(
      'Usuń wszystkie wydarzenia (nieodwracalne)',
      name: 'clearDatabaseDescription',
      desc: '',
      args: [],
    );
  }

  /// `O aplikacji`
  String get about {
    return Intl.message(
      'O aplikacji',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Wersja aplikacji`
  String get version {
    return Intl.message(
      'Wersja aplikacji',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Informacje`
  String get information {
    return Intl.message(
      'Informacje',
      name: 'information',
      desc: '',
      args: [],
    );
  }

  /// `NextDrop - Śledź swoje ulubione serie i programy`
  String get appDescription {
    return Intl.message(
      'NextDrop - Śledź swoje ulubione serie i programy',
      name: 'appDescription',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
