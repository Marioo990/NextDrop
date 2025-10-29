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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(homeEventsProvider);
    final currentTimeView = ref.watch(currentTimeViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).homeTitle),
      ),
      body: Column(
        children: [
          const EventFiltersWidget(compactMode: true),
          _buildTimeViewSelector(context, ref, currentTimeView),
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

  Widget _buildTimeViewSelector(
      BuildContext context,
      WidgetRef ref,
      TimeView currentView,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: TimeView.values.map((view) {
          final isSelected = view == currentView;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  ref.read(currentTimeViewProvider.notifier).state = view;
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: isSelected
                      ? BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFFF00),
                        Color(0xFF9C27B0),
                        Color(0xFF2196F3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  )
                      : BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Text(
                      view.displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, WidgetRef ref, List events) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
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