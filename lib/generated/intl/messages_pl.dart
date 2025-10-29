// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pl locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'pl';

  static String m0(number) => "Odcinek ${number}";
  static String m1(rating) => "Ocena dodana: ${rating}/10";
  static String m2(time) => "za ${time}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("O aplikacji"),
    "addEvent": MessageLookupByLibrary.simpleMessage("Dodaj wydarzenie"),
    "anime": MessageLookupByLibrary.simpleMessage("Anime"),
    "appDescription": MessageLookupByLibrary.simpleMessage(
        "NextDrop - Śledź swoje ulubione serie i programy"),
    "appTitle": MessageLookupByLibrary.simpleMessage("NextDrop"),
    "archiveEvent": MessageLookupByLibrary.simpleMessage("Zarchiwizuj"),
    "archived": MessageLookupByLibrary.simpleMessage("Zakończone"),
    "archivedTitle": MessageLookupByLibrary.simpleMessage("Archiwum"),
    "cancel": MessageLookupByLibrary.simpleMessage("Anuluj"),
    "clearDatabase":
    MessageLookupByLibrary.simpleMessage("Wyczyść całą bazę danych"),
    "clearDatabaseDescription": MessageLookupByLibrary.simpleMessage(
        "Usuń wszystkie wydarzenia (nieodwracalne)"),
    "confirmDelete": MessageLookupByLibrary.simpleMessage(
        "Czy na pewno chcesz usunąć to wydarzenie?"),
    "currentTitle":
    MessageLookupByLibrary.simpleMessage("W trakcie emisji"),
    "dataManagement":
    MessageLookupByLibrary.simpleMessage("Zarządzanie danymi"),
    "defaultNotificationTime":
    MessageLookupByLibrary.simpleMessage("Domyślny czas powiadomienia"),
    "defaultTimeView":
    MessageLookupByLibrary.simpleMessage("Domyślny przedział czasu"),
    "delete": MessageLookupByLibrary.simpleMessage("Usuń"),
    "deleteEvent": MessageLookupByLibrary.simpleMessage("Usuń wydarzenie"),
    "edit": MessageLookupByLibrary.simpleMessage("Edytuj"),
    "editEvent": MessageLookupByLibrary.simpleMessage("Edytuj wydarzenie"),
    "episode": MessageLookupByLibrary.simpleMessage("Odcinek"),
    "episodeNumber": m0,
    "episodes": MessageLookupByLibrary.simpleMessage("Odcinki"),
    "eventCategory": MessageLookupByLibrary.simpleMessage("Kategoria"),
    "eventDeleted":
    MessageLookupByLibrary.simpleMessage("Wydarzenie zostało usunięte"),
    "eventDescription": MessageLookupByLibrary.simpleMessage("Opis"),
    "eventPlatform": MessageLookupByLibrary.simpleMessage("Platforma"),
    "eventSaved":
    MessageLookupByLibrary.simpleMessage("Wydarzenie zostało zapisane"),
    "eventTitle": MessageLookupByLibrary.simpleMessage("Tytuł"),
    "eventType": MessageLookupByLibrary.simpleMessage("Typ"),
    "homeTitle": MessageLookupByLibrary.simpleMessage("Moje wydarzenia"),
    "information": MessageLookupByLibrary.simpleMessage("Informacje"),
    "language": MessageLookupByLibrary.simpleMessage("Język"),
    "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
    "languagePolish": MessageLookupByLibrary.simpleMessage("Polski"),
    "movie": MessageLookupByLibrary.simpleMessage("Film"),
    "notifications": MessageLookupByLibrary.simpleMessage("Powiadomienia"),
    "notificationsDisabled":
    MessageLookupByLibrary.simpleMessage("Powiadomienia wyłączone"),
    "notificationsEnabled":
    MessageLookupByLibrary.simpleMessage("Powiadomienia włączone"),
    "ongoing": MessageLookupByLibrary.simpleMessage("W trakcie"),
    "podcast": MessageLookupByLibrary.simpleMessage("Podcast"),
    "ratingAdded": m1,
    "ratingPrompt":
    MessageLookupByLibrary.simpleMessage("Oceń wydarzenie (1-10):"),
    "rebuildAllEpisodes":
    MessageLookupByLibrary.simpleMessage("Przebuduj wszystkie odcinki"),
    "rebuildDescription": MessageLookupByLibrary.simpleMessage(
        "Usuń i wygeneruj ponownie z poprawnymi godzinami"),
    "save": MessageLookupByLibrary.simpleMessage("Zapisz"),
    "series": MessageLookupByLibrary.simpleMessage("Serial"),
    "settingsTitle": MessageLookupByLibrary.simpleMessage("Ustawienia"),
    "timeIn": m2,
    "tvShow": MessageLookupByLibrary.simpleMessage("Program TV"),
    "upcoming": MessageLookupByLibrary.simpleMessage("Przyszłe"),
    "upcomingTitle": MessageLookupByLibrary.simpleMessage("Przyszłe"),
    "version": MessageLookupByLibrary.simpleMessage("Wersja aplikacji")
  };
}