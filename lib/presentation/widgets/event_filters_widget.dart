import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/enums.dart';
import '../providers/providers.dart';

/// Wspólny widget filtrów używany we wszystkich ekranach
class EventFiltersWidget extends ConsumerWidget {
  final bool showRatingFilter;
  final bool compactMode;

  const EventFiltersWidget({
    super.key,
    this.showRatingFilter = false,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(currentFiltersProvider);

    if (compactMode) {
      return _buildCompactFilters(context, ref, filters);
    }

    return _buildStandardFilters(context, ref, filters);
  }

  Widget _buildStandardFilters(
      BuildContext context,
      WidgetRef ref,
      FilterParams filters,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: showRatingFilter
          ? Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTypeFilter(context, ref, filters),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPlatformFilter(context, ref, filters),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCategoryFilter(context, ref, filters),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRatingFilter(context, ref, filters),
              ),
            ],
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            child: _buildTypeFilter(context, ref, filters),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPlatformFilter(context, ref, filters),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCategoryFilter(context, ref, filters),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilters(
      BuildContext context,
      WidgetRef ref,
      FilterParams filters,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: _buildTypeFilter(context, ref, filters),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: _buildPlatformFilter(context, ref, filters),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: _buildCategoryFilter(context, ref, filters),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeFilter(
      BuildContext context,
      WidgetRef ref,
      FilterParams filters,
      ) {
    return _buildFilterDropdown(
      context: context,
      label: 'Typ',
      value: filters.type?.displayName,
      items: ['Wszystkie', ...EventType.values.map((e) => e.displayName)],
      onChanged: (value) {
        final newType = value == 'Wszystkie'
            ? null
            : EventType.values.firstWhere((e) => e.displayName == value);
        ref.read(currentFiltersProvider.notifier).state = FilterParams(
          type: newType,
          platform: filters.platform,
          category: filters.category,
          minRating: filters.minRating,
        );
      },
    );
  }

  Widget _buildPlatformFilter(
      BuildContext context,
      WidgetRef ref,
      FilterParams filters,
      ) {
    return _buildFilterDropdown(
      context: context,
      label: 'Platforma',
      value: filters.platform,
      items: ['Wszystkie', 'Netflix', 'HBO Max', 'Disney+', 'Apple TV+', 'Amazon Prime', 'Inne'],
      onChanged: (value) {
        ref.read(currentFiltersProvider.notifier).state = FilterParams(
          type: filters.type,
          platform: value == 'Wszystkie' ? null : value,
          category: filters.category,
          minRating: filters.minRating,
        );
      },
    );
  }

  Widget _buildCategoryFilter(
      BuildContext context,
      WidgetRef ref,
      FilterParams filters,
      ) {
    return _buildFilterDropdown(
      context: context,
      label: 'Kategoria',
      value: filters.category,
      items: ['Wszystkie', 'Komedia', 'Dramat', 'Akcja', 'Sci-Fi', 'Fantasy', 'Horror', 'Inne'],
      onChanged: (value) {
        ref.read(currentFiltersProvider.notifier).state = FilterParams(
          type: filters.type,
          platform: filters.platform,
          category: value == 'Wszystkie' ? null : value,
          minRating: filters.minRating,
        );
      },
    );
  }

  Widget _buildRatingFilter(
      BuildContext context,
      WidgetRef ref,
      FilterParams filters,
      ) {
    return _buildFilterDropdown(
      context: context,
      label: 'Min. ocena',
      value: filters.minRating != null ? '${filters.minRating}+' : null,
      items: ['Wszystkie', '5+', '7+', '9+'],
      onChanged: (value) {
        int? minRating;
        if (value == '5+') minRating = 5;
        if (value == '7+') minRating = 7;
        if (value == '9+') minRating = 9;

        ref.read(currentFiltersProvider.notifier).state = FilterParams(
          type: filters.type,
          platform: filters.platform,
          category: filters.category,
          minRating: minRating,
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String label,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 2,
              // Gradient nie działa tutaj, więc użyjemy jednego koloru
              color: Color(0xFFE91E63),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        dropdownColor: const Color(0xFF1a1f3a),
        style: const TextStyle(color: Colors.white, fontSize: 12),
        value: value ?? 'Wszystkie',
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}