import 'package:event_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import '../../../generated/l10n.dart';
import '../../providers/providers.dart';
import '../../widgets/event_card.dart';
import '../../widgets/event_filters_widget.dart';
import '../event_details/event_details_screen.dart';
import '../event_form/event_form_screen.dart';

class CurrentScreen extends ConsumerWidget {
  const CurrentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(ongoingEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).currentTitle),
      ),
      body: Column(
        children: [
          const EventFiltersWidget(),
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
      floatingActionButton: GradientFAB(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EventFormScreen(),
            ),
          );
        },
        icon: Icons.add,
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, WidgetRef ref, List events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).ongoing,
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
          return EventCard(
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventFormScreen(eventId: event.id),
                ),
              ).then((_) => refreshAllEvents(ref));
            },
            onDelete: () async {
              await ref.read(eventRepositoryProvider).deleteEvent(event.id!);
              refreshAllEvents(ref);
            },
            onArchive: () async {
              await _showArchiveDialog(context, ref, event);
            },
          );
        },
      ),
    );
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
      refreshAllEvents(ref);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).eventSaved)),
        );
      }
    }
  }
}