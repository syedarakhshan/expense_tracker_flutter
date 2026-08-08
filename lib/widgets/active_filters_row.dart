import 'package:flutter/material.dart';
import '../core/utils/date_formatter.dart';

/// Shows removable chips for any currently-active filters (category,
/// date range). Renders nothing if no filters are active, so it never
/// takes up space on a clean Home screen.
class ActiveFiltersRow extends StatelessWidget {
  final String? selectedCategory;
  final DateTimeRange? dateRange;
  final VoidCallback onClearCategory;
  final VoidCallback onClearDateRange;
  final VoidCallback onClearAll;

  const ActiveFiltersRow({
    super.key,
    required this.selectedCategory,
    required this.dateRange,
    required this.onClearCategory,
    required this.onClearDateRange,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasCategory = selectedCategory != null;
    final hasDateRange = dateRange != null;

    if (!hasCategory && !hasDateRange) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (hasCategory)
            InputChip(
              label: Text(selectedCategory!),
              avatar: const Icon(Icons.category_outlined, size: 16),
              onDeleted: onClearCategory,
            ),
          if (hasDateRange)
            InputChip(
              label: Text(DateFormatter.formatRange(dateRange!)),
              avatar: const Icon(Icons.date_range, size: 16),
              onDeleted: onClearDateRange,
            ),
          if (hasCategory || hasDateRange)
            TextButton(
              onPressed: onClearAll,
              child: const Text('Clear All'),
            ),
        ],
      ),
    );
  }
}