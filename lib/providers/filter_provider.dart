import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current search query typed into the Home screen search bar.
/// Simple `StateProvider` since it's just a plain string with no
/// side effects — filtering logic lives in the computed provider (5.4).
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Currently selected category filter. `null` means "All categories".
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Optional date range filter — null means "no date filter applied".
/// Set by a date-range picker on the Home screen (wired up in Step 11).
final dateRangeFilterProvider = StateProvider<DateTimeRange?>((ref) => null);