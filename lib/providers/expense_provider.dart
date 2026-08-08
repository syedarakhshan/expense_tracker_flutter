import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/expense_model.dart';
import '../services/expense_database_service.dart';
import 'expense_database_provider.dart';

/// Holds the most recent CRUD error message, or null if the last
/// operation succeeded. The UI (Home, Add Expense, Detail) watches this
/// to show a SnackBar without every screen needing its own try/catch.
final expenseErrorProvider = StateProvider<String?>((ref) => null);

/// Holds the in-memory list of all expenses and exposes CRUD methods.
/// The UI never talks to ExpenseDatabaseService directly — it goes through
/// this notifier, which keeps Riverpod state and Hive storage in sync.
class ExpenseNotifier extends StateNotifier<List<Expense>> {
  final Ref ref;

  ExpenseNotifier(this.ref) : super([]) {
    _loadExpenses();
  }

  void _loadExpenses() {
    try {
      final service = ref.read(expenseDatabaseServiceProvider);
      state = service.getAllExpenses();
    } on ExpenseDatabaseException catch (e) {
      ref.read(expenseErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    String notes = '',
  }) async {
    try {
      final service = ref.read(expenseDatabaseServiceProvider);
      final expense = Expense(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        category: category,
        date: date,
        notes: notes,
        createdAt: DateTime.now(),
      );
      await service.addExpense(expense);
      _loadExpenses();
    } on ExpenseDatabaseException catch (e) {
      ref.read(expenseErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> updateExpense(Expense updated) async {
    try {
      final service = ref.read(expenseDatabaseServiceProvider);
      await service.updateExpense(updated);
      _loadExpenses();
    } on ExpenseDatabaseException catch (e) {
      ref.read(expenseErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final service = ref.read(expenseDatabaseServiceProvider);
      await service.deleteExpense(id);
      _loadExpenses();
    } on ExpenseDatabaseException catch (e) {
      ref.read(expenseErrorProvider.notifier).state = e.message;
    }
  }

  /// Re-inserts a previously deleted expense with its ORIGINAL id/createdAt
  /// (unlike addExpense, which always generates a new id). Powers the
  /// "Undo" action on the delete SnackBar.
  Future<void> restoreExpense(Expense expense) async {
    try {
      final service = ref.read(expenseDatabaseServiceProvider);
      await service.addExpense(expense);
      _loadExpenses();
    } on ExpenseDatabaseException catch (e) {
      ref.read(expenseErrorProvider.notifier).state = e.message;
    }
  }

  void refresh() => _loadExpenses();
}

final expenseListProvider =
StateNotifierProvider<ExpenseNotifier, List<Expense>>((ref) {
  return ExpenseNotifier(ref);
});