import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../generated/l10n.dart';
import '../../providers/providers.dart';
import '../../widgets/event_card.dart';
import '../../widgets/event_filters_widget.dart';
import '../event_details/event_details_screen.dart';

class ArchivedScreen extends ConsumerWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(archivedEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).archivedTitle),
      ),
      body: Column(
        children: [
          const EventFiltersWidget(showRatingFilter: true),
          Expanded(
            child: eventsAsync.when(
              data: (events) => _buildEventsList(context, ref, events),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, WidgetRef ref, List events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.archive_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).archived,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        refreshAllEvents(ref);
      },
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Column(
            children: [
              EventCard(
                event: event,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsScreen(eventId: event.id!),
                    ),
                  ).then((_) => refreshAllEvents(ref));
                },
                onEdit: () {
                  _showEditRatingDialog(context, ref, event);
                },
                onDelete: () async {
                  final confirm = await _showDeleteConfirmation(context);
                  if (confirm) {
                    await ref.read(eventRepositoryProvider).deleteEvent(event.id!);
                    refreshAllEvents(ref);
                  }
                },
              ),
              _buildRatingActionButton(context, ref, event),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatingActionButton(BuildContext context, WidgetRef ref, dynamic event) {
    final hasRating = event.rating != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: OutlinedButton.icon(
        onPressed: () => _showEditRatingDialog(context, ref, event),
        icon: Icon(
          hasRating ? Icons.edit : Icons.star_border,
          color: hasRating ? const Color(0xFF2196F3) : Colors.amber,
        ),
        label: Text(
          hasRating
              ? '${S.of(context).edit} (${event.rating}/10)'
              : S.of(context).ratingPrompt,
          style: TextStyle(
            color: hasRating ? const Color(0xFF2196F3) : Colors.amber,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: hasRating ? const Color(0xFF2196F3) : Colors.amber,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Future<void> _showEditRatingDialog(
      BuildContext context,
      WidgetRef ref,
      dynamic event,
      ) async {
    int? rating = event.rating;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1a1f3a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                event.rating == null ? Icons.star_border : Icons.edit,
                color: const Color(0xFFE91E63),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.rating == null
                      ? S.of(context).ratingPrompt
                      : S.of(context).edit,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (event.rating != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2196F3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${S.of(context).ongoing}: ${event.rating}/10',
                    style: const TextStyle(
                      color: Color(0xFF2196F3),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                S.of(context).ratingPrompt,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(10, (index) {
                  final value = index + 1;
                  final isSelected = rating == value;
                  final isCurrentRating = event.rating == value;

                  return InkWell(
                    onTap: () => setState(() => rating = value),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                          colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                        )
                            : null,
                        color: isSelected
                            ? null
                            : isCurrentRating
                            ? const Color(0xFF2196F3).withOpacity(0.3)
                            : const Color(0xFF2a2f4a),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : isCurrentRating
                              ? const Color(0xFF2196F3)
                              : Colors.grey[700]!,
                          width: isSelected || isCurrentRating ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isCurrentRating
                                ? const Color(0xFF2196F3)
                                : Colors.grey[400],
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
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextButton(
                onPressed: rating != null ? () => Navigator.pop(context, rating) : null,
                child: Text(
                  event.rating == null ? S.of(context).save : S.of(context).save,
                  style: TextStyle(
                    color: rating != null ? Colors.white : Colors.white54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && result != event.rating) {
      final updatedEvent = event.copyWith(rating: result);
      await ref.read(eventRepositoryProvider).updateEvent(updatedEvent);
      refreshAllEvents(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).ratingAdded(result)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    ) ??
        false;
  }
}