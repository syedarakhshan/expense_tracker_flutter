import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'expense_provider.dart';
import 'filter_provider.dart';
import 'income_provider.dart';

final filteredExpensesProvider = Provider((ref) {
  final expenses = ref.watch(expenseListProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryFilterProvider);
  final dateRange = ref.watch(dateRangeFilterProvider);

  return expenses.where((expense) {
    final matchesQuery = query.isEmpty ||
        expense.title.toLowerCase().contains(query) ||
        expense.notes.toLowerCase().contains(query);

    final matchesCategory = category == null || expense.category == category;

    final matchesDate = dateRange == null ||
        (!expense.date.isBefore(dateRange.start) &&
            !expense.date.isAfter(dateRange.end.add(const Duration(days: 1))));

    return matchesQuery && matchesCategory && matchesDate;
  }).toList();
});

final totalExpenseProvider = Provider<double>((ref) {
  final expenses = ref.watch(expenseListProvider);
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
});

/// Total income is the sum of all logged fee payments (income ledger),
/// not a single manually-set number.
final totalIncomeProvider = Provider<double>((ref) {
  final entries = ref.watch(incomeListProvider);
  return entries.fold(0.0, (sum, e) => sum + e.amount);
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);
  return income - expense;
});

final categoryTotalsProvider = Provider<Map<String, double>>((ref) {
  final expenses = ref.watch(expenseListProvider);
  final Map<String, double> totals = {};
  for (final expense in expenses) {
    totals.update(
      expense.category,
          (value) => value + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return totals;
});