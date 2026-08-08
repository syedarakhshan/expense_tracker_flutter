import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'expense_provider.dart';

/// One data point for the monthly bar chart.
class MonthlyTotal {
  final String label; // e.g. "Mar"
  final double total;
  final DateTime monthStart; // used for chronological sorting

  MonthlyTotal({
    required this.label,
    required this.total,
    required this.monthStart,
  });
}

/// Totals for the last 6 months (including the current month), oldest
/// first, so the bar chart reads left-to-right chronologically.
/// Months with no expenses still appear, with a total of 0.
final monthlyTotalsProvider = Provider<List<MonthlyTotal>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final now = DateTime.now();

  const monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // Build the last 6 month buckets, oldest first.
  final months = List.generate(6, (i) {
    final monthsAgo = 5 - i;
    final target = DateTime(now.year, now.month - monthsAgo, 1);
    return target;
  });

  return months.map((monthStart) {
    final total = expenses
        .where((e) =>
    e.type == 'expense' &&
        e.date.year == monthStart.year &&
        e.date.month == monthStart.month)
        .fold(0.0, (sum, e) => sum + e.amount);

    return MonthlyTotal(
      label: monthLabels[monthStart.month - 1],
      total: total,
      monthStart: monthStart,
    );
  }).toList();
});