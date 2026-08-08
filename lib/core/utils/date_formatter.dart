import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatMedium(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return formatMedium(date);
  }

  /// e.g. "Aug 1 – Aug 6, 2026" — used for the date-range filter chip.
  static String formatRange(DateTimeRange range) {
    return '${DateFormat.MMMd().format(range.start)} - ${formatMedium(range.end)}';
  }
}