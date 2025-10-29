// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(number) => "Episode ${number}";

  static String m1(rating) => "Rating added: ${rating}/10";

  static String m2(time) => "in ${time}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "addEvent": MessageLookupByLibrary.simpleMessage("Add Event"),
        "anime": MessageLookupByLibrary.simpleMessage("Anime"),
        "appDescription": MessageLookupByLibrary.simpleMessage(
            "NextDrop - Track your favorite shows and programs"),
        "appTitle": MessageLookupByLibrary.simpleMessage("NextDrop"),
        "archiveEvent": MessageLookupByLibrary.simpleMessage("Archive"),
        "archived": MessageLookupByLibrary.simpleMessage("Finished"),
        "archivedTitle": MessageLookupByLibrary.simpleMessage("Archive"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "clearDatabase":
            MessageLookupByLibrary.simpleMessage("Clear entire database"),
        "clearDatabaseDescription": MessageLookupByLibrary.simpleMessage(
            "Delete all events (irreversible)"),
        "confirmDelete": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this event?"),
        "currentTitle":
            MessageLookupByLibrary.simpleMessage("Currently Airing"),
        "dataManagement":
            MessageLookupByLibrary.simpleMessage("Data management"),
        "defaultNotificationTime":
            MessageLookupByLibrary.simpleMessage("Default notification time"),
        "defaultTimeView":
            MessageLookupByLibrary.simpleMessage("Default time view"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteEvent": MessageLookupByLibrary.simpleMessage("Delete Event"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editEvent": MessageLookupByLibrary.simpleMessage("Edit Event"),
        "episode": MessageLookupByLibrary.simpleMessage("Episode"),
        "episodeNumber": m0,
        "episodes": MessageLookupByLibrary.simpleMessage("Episodes"),
        "eventCategory": MessageLookupByLibrary.simpleMessage("Category"),
        "eventDeleted":
            MessageLookupByLibrary.simpleMessage("Event has been deleted"),
        "eventDescription": MessageLookupByLibrary.simpleMessage("Description"),
        "eventPlatform": MessageLookupByLibrary.simpleMessage("Platform"),
        "eventSaved":
            MessageLookupByLibrary.simpleMessage("Event has been saved"),
        "eventTitle": MessageLookupByLibrary.simpleMessage("Title"),
        "eventType": MessageLookupByLibrary.simpleMessage("Type"),
        "homeTitle": MessageLookupByLibrary.simpleMessage("My Events"),
        "information": MessageLookupByLibrary.simpleMessage("Information"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "languageEnglish": MessageLookupByLibrary.simpleMessage("English"),
        "languagePolish": MessageLookupByLibrary.simpleMessage("Polski"),
        "movie": MessageLookupByLibrary.simpleMessage("Movie"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "notificationsDisabled":
            MessageLookupByLibrary.simpleMessage("Notifications disabled"),
        "notificationsEnabled":
            MessageLookupByLibrary.simpleMessage("Notifications enabled"),
        "ongoing": MessageLookupByLibrary.simpleMessage("Ongoing"),
        "podcast": MessageLookupByLibrary.simpleMessage("Podcast"),
        "ratingAdded": m1,
        "ratingPrompt":
            MessageLookupByLibrary.simpleMessage("Rate this event (1-10):"),
        "rebuildAllEpisodes":
            MessageLookupByLibrary.simpleMessage("Rebuild all episodes"),
        "rebuildDescription": MessageLookupByLibrary.simpleMessage(
            "Delete and regenerate with correct times"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "series": MessageLookupByLibrary.simpleMessage("Series"),
        "settingsTitle": MessageLookupByLibrary.simpleMessage("Settings"),
        "timeIn": m2,
        "tvShow": MessageLookupByLibrary.simpleMessage("TV Show"),
        "upcoming": MessageLookupByLibrary.simpleMessage("Upcoming"),
        "upcomingTitle": MessageLookupByLibrary.simpleMessage("Upcoming"),
        "version": MessageLookupByLibrary.simpleMessage("Version")
      };
}
