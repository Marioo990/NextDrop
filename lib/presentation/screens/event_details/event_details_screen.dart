import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/enums.dart';
import '../../../domain/entities/episode.dart';
import '../../../generated/l10n.dart';
import '../../providers/providers.dart';
import '../../widgets/event_image_widget.dart';
import '../episodes/episodes_list_screen.dart';
import '../event_form/event_form_screen.dart';

class EventDetailsScreen extends ConsumerWidget {
  final int eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailProvider(eventId));

    return eventAsync.when(
      data: (event) {
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: Text(S.of(context).eventTitle)),
            body: Center(child: Text(S.of(context).eventTitle)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).eventTitle),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventFormScreen(eventId: eventId),
                        ),
                      ).then((_) {
                        ref.invalidate(eventDetailProvider(eventId));
                        ref.invalidate(episodesByEventProvider(eventId));
                        refreshAllEvents(ref);
                      });
                      break;
                    case 'archive':
                      await _showArchiveDialog(context, ref, event);
                      break;
                    case 'delete':
                      await _showDeleteDialog(context, ref, event);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(S.of(context).edit),
                      ],
                    ),
                  ),
                  if (event.status != EventStatus.archived)
                    PopupMenuItem(
                      value: 'archive',
                      child: Row(
                        children: [
                          const Icon(Icons.archive),
                          const SizedBox(width: 8),
                          Text(S.of(context).archiveEvent),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(event),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(event),
                      const SizedBox(height: 12),
                      _buildBadges(context, event),
                      const SizedBox(height: 24),
                      _buildInfoSection(context, ref, event),
                      if (event.description != null) ...[
                        const SizedBox(height: 24),
                        _buildDescriptionSection(context, event),
                      ],
                      if (event.userNote != null) ...[
                        const SizedBox(height: 24),
                        _buildNoteSection(event),
                      ],
                      const SizedBox(height: 24),
                      _buildNotificationToggle(context, ref, event),
                      const SizedBox(height: 32),
                      _buildEditButton(context, ref, event),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(S.of(context).eventTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(S.of(context).eventTitle)),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildImage(dynamic event) {
    return Center(
      child: EventImageWidgetWithHero(
        imagePath: event.imagePath,
        width: 150,
        height: 200,
        heroTag: 'event_image_${event.id}',
      ),
    );
  }

  Widget _buildTitle(dynamic event) {
    return Text(
      event.title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBadges(BuildContext context, dynamic event) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(
          event.type.displayName,
          _getTypeColor(event.type),
        ),
        _buildBadge(
          event.category,
          Colors.purple,
        ),
        _buildBadge(
          event.platform,
          Colors.blue,
        ),
        _buildBadge(
          event.status.displayName,
          _getStatusColor(event.status),
        ),
        if (event.status == EventStatus.archived && event.rating != null)
          _buildBadge(
            '⭐ ${event.rating}/10',
            Colors.amber,
          ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, WidgetRef ref, dynamic event) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).eventDescription,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          Icons.calendar_today,
          'Start date',
          dateFormat.format(event.startDate),
        ),
        if (event.startTime != null)
          _buildInfoRow(
            Icons.access_time,
            'Time',
            '${event.startTime!.hour.toString().padLeft(2, '0')}:${event.startTime!.minute.toString().padLeft(2, '0')}',
          ),
        _buildInfoRow(
          Icons.repeat,
          'Recurrence',
          event.recurrence.displayName,
        ),
        if (event.publisher != null)
          _buildInfoRow(
            Icons.business,
            'Publisher',
            event.publisher!,
          ),
        if (event.totalEpisodes != null && event.totalEpisodes! > 0)
          _buildEpisodesSection(context, ref, event),
        if (event.endDate != null)
          _buildInfoRow(
            Icons.event_available,
            'End date',
            dateFormat.format(event.endDate!),
          ),
      ],
    );
  }

  Widget _buildEpisodesSection(BuildContext context, WidgetRef ref, dynamic event) {
    final episodesAsync = ref.watch(episodesByEventProvider(event.id!));

    return episodesAsync.when(
      data: (episodes) {
        if (episodes.isEmpty) return const SizedBox.shrink();

        const maxDisplayed = 25;
        final displayedEpisodes = episodes.take(maxDisplayed).toList();
        final remainingCount = episodes.length - maxDisplayed;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).episodes,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EpisodesListScreen(
                          eventId: event.id!,
                          eventTitle: event.title,
                        ),
                      ),
                    );
                  },
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...displayedEpisodes.map((episode) {
              final now = DateTime.now();

              EpisodeStatus currentStatus = episode.status;
              if (currentStatus == EpisodeStatus.upcoming && episode.airDate.isBefore(now)) {
                currentStatus = EpisodeStatus.aired;
              }

              Color statusColor;
              IconData statusIcon;

              switch (currentStatus) {
                case EpisodeStatus.aired:
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case EpisodeStatus.skipped:
                  statusColor = Colors.blue;
                  statusIcon = Icons.schedule;
                  break;
                case EpisodeStatus.upcoming:
                  statusColor = Colors.orange;
                  statusIcon = Icons.schedule;
                  break;
              }

              final dateTimeFormat = DateFormat('dd.MM HH:mm');

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).episodeNumber(episode.episodeNumber),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      dateTimeFormat.format(episode.airDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (remainingCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    '+ $remainingCount more',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Divider(),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, dynamic event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).eventDescription,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event.description!,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection(dynamic event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My note',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            event.userNote!,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle(
      BuildContext context,
      WidgetRef ref,
      dynamic event,
      ) {
    return Card(
      child: SwitchListTile(
        title: Text(S.of(context).notifications),
        subtitle: Text(
          event.notificationsEnabled
              ? S.of(context).notificationsEnabled
              : S.of(context).notificationsDisabled,
        ),
        value: event.notificationsEnabled,
        onChanged: (value) async {
          final updatedEvent = event.copyWith(
            notificationsEnabled: value,
          );
          await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);
          ref.invalidate(eventDetailProvider(event.id));
        },
      ),
    );
  }

  Widget _buildEditButton(
      BuildContext context,
      WidgetRef ref,
      dynamic event,
      ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventFormScreen(eventId: event.id),
                ),
              ).then((_) {
                ref.invalidate(eventDetailProvider(event.id));
                ref.invalidate(episodesByEventProvider(event.id));
                refreshAllEvents(ref);
              });
            },
            icon: const Icon(Icons.edit),
            label: Text(S.of(context).editEvent),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        if (event.totalEpisodes != null && event.totalEpisodes! > 0) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EpisodesListScreen(
                      eventId: event.id!,
                      eventTitle: event.title,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: Text('${S.of(context).episodes} (${event.totalEpisodes})'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Color _getTypeColor(EventType type) {
    switch (type) {
      case EventType.series:
        return Colors.purple;
      case EventType.anime:
        return Colors.pink;
      case EventType.podcast:
        return Colors.green;
      case EventType.tvShow:
        return Colors.orange;
      case EventType.movie:
        return Colors.purpleAccent;
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return Colors.blue;
      case EventStatus.ongoing:
        return Colors.orange;
      case EventStatus.archived:
        return Colors.grey;
    }
  }

  Future<void> _showArchiveDialog(
      BuildContext context,
      WidgetRef ref,
      dynamic event,
      ) async {
    int? rating;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1a1f3a),
          title: Text(
            S.of(context).archiveEvent,
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(context).ratingPrompt,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (index) {
                  final value = index + 1;
                  final isSelected = rating == value;
                  return InkWell(
                    onTap: () => setState(() => rating = value),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, rating),
              child: Text(S.of(context).archiveEvent),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final updatedEvent = event.copyWith(
        status: EventStatus.archived,
        rating: result,
        endDate: DateTime.now(),
      );

      await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).eventSaved)),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(
      BuildContext context,
      WidgetRef ref,
      dynamic event,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: Text(
          S.of(context).deleteEvent,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          S.of(context).confirmDelete,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(eventRepositoryProvider).deleteEvent(event.id!);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).eventDeleted)),
        );
      }
    }
  }
}