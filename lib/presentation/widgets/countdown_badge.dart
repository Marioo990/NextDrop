import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/event.dart';
import '../providers/providers.dart';

class CountdownBadge extends StatefulWidget {
  final Event event;

  const CountdownBadge({
    super.key,
    required this.event,
  });

  @override
  State<CountdownBadge> createState() => _CountdownBadgeState();
}

class _CountdownBadgeState extends State<CountdownBadge> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Odświeżaj co 30 sekund zamiast co minutę przez provider
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Episode? _findNextEpisode(List<Episode> episodes) {
    final upcomingEpisodes = episodes
        .where((ep) => ep.status == EpisodeStatus.upcoming && ep.airDate.isAfter(_now))
        .toList();

    if (upcomingEpisodes.isEmpty) return null;

    upcomingEpisodes.sort((a, b) => a.airDate.compareTo(b.airDate));
    return upcomingEpisodes.first;
  }

  String _formatCountdown(DateTime targetDate) {
    final difference = targetDate.difference(_now);

    if (difference.isNegative) {
      return 'Now available';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return 'soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final episodesAsync = ref.watch(episodesByEventProvider(widget.event.id!));

        return episodesAsync.when(
          data: (episodes) {
            final nextEpisode = _findNextEpisode(episodes);

            if (nextEpisode == null) {
              return const SizedBox.shrink();
            }

            DateTime targetDateTime = nextEpisode.airDate;

            if (widget.event.startTime != null) {
              targetDateTime = DateTime(
                nextEpisode.airDate.year,
                nextEpisode.airDate.month,
                nextEpisode.airDate.day,
                widget.event.startTime!.hour,
                widget.event.startTime!.minute,
              );
            }

            final countdownText = _formatCountdown(targetDateTime);

            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurpleAccent.withOpacity(0.3),
                    Colors.deepPurpleAccent.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Color(0xFF9966CC),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    countdownText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9966CC),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }
}