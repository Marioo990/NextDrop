import 'package:event_tracker/presentation/widgets/event_image_widget.dart';
import '../../core/constants/enums.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/event.dart';
import 'countdown_badge.dart';

class EventCard extends ConsumerWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onArchive,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('event_${event.id}'),
      background: _buildSwipeBackground(
        color: const Color(0xFF2196F3),
        icon: Icons.edit,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: const Color(0xFFE91E63),
        icon: Icons.delete,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onEdit != null) {
          onEdit!();
          return false;
        } else if (direction == DismissDirection.endToStart && onDelete != null) {
          final confirm = await _showDeleteConfirmation(context);
          if (confirm) {
            onDelete!();
          }
          return confirm;
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [

              const Color(0xFFCDDC39),
              const Color(0xFFFF5722),
              const Color(0xFFFF00FF),
              const Color(0xFF8A2BE2),
              const Color(0xFF003366),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E63).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(2), // Grubość ramki gradientowej
          decoration: BoxDecoration(
            color: Colors.black, // Czarne tło
            borderRadius: BorderRadius.circular(18),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildTitle(),
                          const SizedBox(height: 4),
                          _buildDateTime(),
                          const SizedBox(height: 8),
                          _buildBadges(),
                          if (event.totalEpisodes != null &&
                              event.totalEpisodes! > 0 &&
                              event.id != null)
                            CountdownBadge(event: event),
                        ],
                      ),
                    ),
                    if (event.notificationsEnabled)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE040FB), Color(0xFF003366)],
                            // colors: [Color(0xFFE91E63), Color(0xFF2196F3)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: EventImageWidgetWithHero(
        imagePath: event.imagePath,
        width: 80,
        height: 120,
        heroTag: 'event_image_${event.id}',
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      event.title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTime() {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeStr = event.startTime != null
        ? ' • ${event.startTime!.hour.toString().padLeft(2, '0')}:${event.startTime!.minute.toString().padLeft(2, '0')}'
        : '';

    return Text(
      '${dateFormat.format(event.startDate)}$timeStr',
      style: TextStyle(
        fontSize: 13,
        color: Colors.white.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBadges() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        _buildBadge(
          event.type.displayName,
          _getTypeColor(event.type),
        ),
        _buildBadge(
          event.platform,
          const Color(0xFF2196F3),
        ),
        _buildBadge(
          event.category,
          const Color(0xFF00FFFF), // Fioletowy dla kategorii
        ),
        if (event.status == EventStatus.archived && event.rating != null)
          _buildBadge(
            '⭐ ${event.rating}/10',
            const Color(0xFFFFB300),
          ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getTypeColor(EventType type) {
    switch (type) {
      case EventType.series:
        return const Color(0xFFCDDC39); // Fioletowy
      case EventType.anime:
        return const Color(0xFFFF5722); // Różowy
      case EventType.podcast:
        return const Color(0xFF4CAF50); // Zielony
      case EventType.tvShow:
        return const Color(0xFF2196F3);
      case EventType.movie:
        return const Color(0xFFDDA0DD); // Niebieski
    }
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1f3a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Usuń wydarzenie',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Czy na pewno chcesz usunąć to wydarzenie?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Anuluj',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3),Color(0xFFE91E63)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Usuń',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}