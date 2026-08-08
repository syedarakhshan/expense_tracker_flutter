import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../models/expense_model.dart';

/// Thrown when a database operation fails, so callers get a clear,
/// app-specific error instead of a raw Hive/platform exception.
class ExpenseDatabaseException implements Exception {
  final String message;
  ExpenseDatabaseException(this.message);

  @override
  String toString() => message;
}

class ExpenseDatabaseService {
  Box<Expense>? _box;

  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ExpenseAdapter());
      }
      _box = await Hive.openBox<Expense>(AppConstants.expenseBoxName);
    } catch (e) {
      throw ExpenseDatabaseException('Failed to initialize database: $e');
    }
  }

  Box<Expense> get _requireBox {
    if (_box == null) {
      throw ExpenseDatabaseException(
        'Database not initialized. Call init() before use.',
      );
    }
    return _box!;
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _requireBox.put(expense.id, expense);
    } catch (e) {
      throw ExpenseDatabaseException('Failed to add expense: $e');
    }
  }

  List<Expense> getAllExpenses() {
    try {
      final expenses = _requireBox.values.toList();
      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      throw ExpenseDatabaseException('Failed to load expenses: $e');
    }
  }

  Expense? getExpenseById(String id) {
    try {
      return _requireBox.get(id);
    } catch (e) {
      throw ExpenseDatabaseException('Failed to fetch expense: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _requireBox.put(expense.id, expense);
    } catch (e) {
      throw ExpenseDatabaseException('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _requireBox.delete(id);
    } catch (e) {
      throw ExpenseDatabaseException('Failed to delete expense: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _requireBox.clear();
    } catch (e) {
      throw ExpenseDatabaseException('Failed to clear expenses: $e');
    }
  }

  double getTotalIncome() => 0.0;

  double getTotalExpense() {
    try {
      return _requireBox.values.fold(0.0, (sum, e) => sum + e.amount);
    } catch (e) {
      throw ExpenseDatabaseException('Failed to calculate total: $e');
    }
  }

  double getBalance() => getTotalIncome() - getTotalExpense();
}