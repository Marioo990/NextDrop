import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/episode.dart';
import '../../../generated/l10n.dart';
import '../../providers/providers.dart';

class EpisodesListScreen extends ConsumerWidget {
  final int eventId;
  final String eventTitle;

  const EpisodesListScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final episodesAsync = ref.watch(episodesByEventProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${S.of(context).episodes} - $eventTitle'),
      ),
      body: episodesAsync.when(
        data: (episodes) {
          if (episodes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.tv_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).episodes,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final sortedEpisodes = List<Episode>.from(episodes)
            ..sort((a, b) {
              final numCompare = a.episodeNumber.compareTo(b.episodeNumber);
              if (numCompare != 0) return numCompare;

              if (a.status == EpisodeStatus.skipped &&
                  b.status != EpisodeStatus.skipped) {
                return -1;
              } else if (a.status != EpisodeStatus.skipped &&
                  b.status == EpisodeStatus.skipped) {
                return 1;
              }
              return 0;
            });

          return ListView.builder(
            itemCount: sortedEpisodes.length,
            itemBuilder: (context, index) {
              final episode = sortedEpisodes[index];
              return _buildEpisodeCard(context, ref, episode, episodes);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildEpisodeCard(
      BuildContext context,
      WidgetRef ref,
      Episode episode,
      List<Episode> allEpisodes,
      ) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(statusIcon, color: statusColor, size: 20),
        ),
        title: Text(
          S.of(context).episodeNumber(episode.episodeNumber),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(episode.airDate),
              style: TextStyle(
                color: currentStatus == EpisodeStatus.skipped
                    ? Colors.blue
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (currentStatus == EpisodeStatus.skipped)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Original date',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        trailing: currentStatus == EpisodeStatus.upcoming
            ? PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) async {
            if (value == 'skip') {
              await _showSkipDialog(context, ref, episode, allEpisodes);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'skip',
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Postponed'),
                ],
              ),
            ),
          ],
        )
            : null,
      ),
    );
  }

  Future<void> _showSkipDialog(
      BuildContext context,
      WidgetRef ref,
      Episode episode,
      List<Episode> allEpisodes,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        title: const Text(
          'Postponed',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Postpone episode ${episode.episodeNumber}?\n\n'
              '• Original episode ${episode.episodeNumber} will be marked as postponed\n'
              '• New episode ${episode.episodeNumber} will be created with next date\n'
              '• All following episodes will be shifted by one cycle',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Postpone'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        int intervalDays = 7;
        if (allEpisodes.length > 1) {
          Episode? firstNormalEpisode;
          Episode? secondNormalEpisode;

          for (var ep in allEpisodes) {
            if (ep.status != EpisodeStatus.skipped) {
              if (firstNormalEpisode == null) {
                firstNormalEpisode = ep;
              } else if (secondNormalEpisode == null) {
                secondNormalEpisode = ep;
                break;
              }
            }
          }

          if (firstNormalEpisode != null && secondNormalEpisode != null) {
            intervalDays = secondNormalEpisode.airDate
                .difference(firstNormalEpisode.airDate)
                .inDays;
          }
        }

        await ref.read(episodeRepositoryProvider).postponeEpisode(
          episode.id!,
          eventId,
          intervalDays,
        );

        ref.invalidate(episodesByEventProvider(eventId));

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Episode ${episode.episodeNumber} postponed.\n'
                    'Created new episode ${episode.episodeNumber} and shifted remaining.',
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}