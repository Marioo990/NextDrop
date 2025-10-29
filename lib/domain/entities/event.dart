import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';

class Event extends Equatable {
  final int? id;
  final String title;
  final DateTime startDate;
  final TimeOfDay? startTime;
  final Recurrence recurrence;
  final int? recurrenceInterval;
  final WeekDay? recurrenceDay;
  final int? batchSize;
  final EventType type;
  final String category;
  final String platform;
  final String? imagePath;
  final String? publisher;
  final String? description;
  final String? userNote;
  final bool notificationsEnabled;
  final int? notificationMinutes;
  final EventStatus status;
  final int? rating;
  final DateTime? endDate;
  final int? totalEpisodes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    this.id,
    required this.title,
    required this.startDate,
    this.startTime,
    required this.recurrence,
    this.recurrenceInterval,
    this.recurrenceDay,
    this.batchSize,
    required this.type,
    required this.category,
    required this.platform,
    this.imagePath,
    this.publisher,
    this.description,
    this.userNote,
    this.notificationsEnabled = true,
    this.notificationMinutes,
    this.status = EventStatus.upcoming,
    this.rating,
    this.endDate,
    this.totalEpisodes,
    required this.createdAt,
    required this.updatedAt,
  });

  Event copyWith({
    int? id,
    String? title,
    DateTime? startDate,
    TimeOfDay? startTime,
    Recurrence? recurrence,
    int? recurrenceInterval,
    WeekDay? recurrenceDay,
    int? batchSize,
    EventType? type,
    String? category,
    String? platform,
    String? imagePath,
    String? publisher,
    String? description,
    String? userNote,
    bool? notificationsEnabled,
    int? notificationMinutes,
    EventStatus? status,
    int? rating,
    DateTime? endDate,
    int? totalEpisodes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      recurrence: recurrence ?? this.recurrence,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
      recurrenceDay: recurrenceDay ?? this.recurrenceDay,
      batchSize: batchSize ?? this.batchSize,
      type: type ?? this.type,
      category: category ?? this.category,
      platform: platform ?? this.platform,
      imagePath: imagePath ?? this.imagePath,
      publisher: publisher ?? this.publisher,
      description: description ?? this.description,
      userNote: userNote ?? this.userNote,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationMinutes: notificationMinutes ?? this.notificationMinutes,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      endDate: endDate ?? this.endDate,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    startDate,
    startTime,
    recurrence,
    recurrenceInterval,
    recurrenceDay,
    batchSize,
    type,
    category,
    platform,
    imagePath,
    publisher,
    description,
    userNote,
    notificationsEnabled,
    notificationMinutes,
    status,
    rating,
    endDate,
    totalEpisodes,
    createdAt,
    updatedAt,
  ];
}