import 'package:event_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../generated/l10n.dart';
import '../../providers/providers.dart';
import '../../widgets/event_card.dart';
import '../../widgets/event_filters_widget.dart';
import '../event_details/event_details_screen.dart';
import '../event_form/event_form_screen.dart';

class UpcomingScreen extends ConsumerWidget {
  const UpcomingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).upcomingTitle),
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
            const Icon(Icons.schedule, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).upcoming,
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
          );
        },
      ),
    );
  }
}