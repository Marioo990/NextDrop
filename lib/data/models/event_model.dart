import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    super.id,
    required super.title,
    required super.startDate,
    super.startTime,
    required super.recurrence,
    super.recurrenceInterval,
    super.recurrenceDay,
    super.batchSize,
    required super.type,
    required super.category,
    required super.platform,
    super.imagePath,
    super.publisher,
    super.description,
    super.userNote,
    super.notificationsEnabled = true,
    super.notificationMinutes,
    super.status = EventStatus.upcoming,
    super.rating,
    super.endDate,
    super.totalEpisodes,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      startDate: event.startDate,
      startTime: event.startTime,
      recurrence: event.recurrence,
      recurrenceInterval: event.recurrenceInterval,
      recurrenceDay: event.recurrenceDay,
      batchSize: event.batchSize,
      type: event.type,
      category: event.category,
      platform: event.platform,
      imagePath: event.imagePath,
      publisher: event.publisher,
      description: event.description,
      userNote: event.userNote,
      notificationsEnabled: event.notificationsEnabled,
      notificationMinutes: event.notificationMinutes,
      status: event.status,
      rating: event.rating,
      endDate: event.endDate,
      totalEpisodes: event.totalEpisodes,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_date': startDate.millisecondsSinceEpoch,
      'start_time': startTime != null
          ? '${startTime!.hour}:${startTime!.minute}'
          : null,
      'recurrence': recurrence.value,
      'recurrence_interval': recurrenceInterval,
      'recurrence_day': recurrenceDay?.value,
      'batch_size': batchSize,
      'type': type.value,
      'category': category,
      'platform': platform,
      'image_path': imagePath,
      'publisher': publisher,
      'description': description,
      'user_note': userNote,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'notification_minutes': notificationMinutes,
      'status': status.value,
      'rating': rating,
      'end_date': endDate?.millisecondsSinceEpoch,
      'total_episodes': totalEpisodes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return EventModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      startTime: parseTime(map['start_time'] as String?),
      recurrence: Recurrence.fromString(map['recurrence'] as String),
      recurrenceInterval: map['recurrence_interval'] as int?,
      recurrenceDay: map['recurrence_day'] != null
          ? WeekDay.fromInt(map['recurrence_day'] as int)
          : null,
      batchSize: map['batch_size'] as int?,
      type: EventType.fromString(map['type'] as String),
      category: map['category'] as String,
      platform: map['platform'] as String,
      imagePath: map['image_path'] as String?,
      publisher: map['publisher'] as String?,
      description: map['description'] as String?,
      userNote: map['user_note'] as String?,
      notificationsEnabled: (map['notifications_enabled'] as int) == 1,
      notificationMinutes: map['notification_minutes'] as int?,
      status: EventStatus.fromString(map['status'] as String),
      rating: map['rating'] as int?,
      totalEpisodes: map['total_episodes'] as int?,
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
}