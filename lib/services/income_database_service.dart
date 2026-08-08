import 'package:hive_flutter/hive_flutter.dart';
import '../models/income_model.dart';

class IncomeDatabaseException implements Exception {
  final String message;
  IncomeDatabaseException(this.message);

  @override
  String toString() => message;
}

/// Same pattern as ExpenseDatabaseService, but for income records.
/// Kept as a separate box/service (not merged into Expense) since income
/// and expenses have different fields (studentName vs. category) and
/// different meaning — mixing them into one model would force awkward
/// nullable fields on both sides.
class IncomeDatabaseService {
  Box<IncomeEntry>? _box;

  Future<void> init() async {
    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(IncomeEntryAdapter());
      }
      _box = await Hive.openBox<IncomeEntry>('incomes');
    } catch (e) {
      throw IncomeDatabaseException('Failed to initialize income database: $e');
    }
  }

  Box<IncomeEntry> get _requireBox {
    if (_box == null) {
      throw IncomeDatabaseException(
        'Income database not initialized. Call init() before use.',
      );
    }
    return _box!;
  }

  Future<void> addIncome(IncomeEntry entry) async {
    try {
      await _requireBox.put(entry.id, entry);
    } catch (e) {
      throw IncomeDatabaseException('Failed to add income: $e');
    }
  }

  List<IncomeEntry> getAllIncome() {
    try {
      final entries = _requireBox.values.toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (e) {
      throw IncomeDatabaseException('Failed to load income: $e');
    }
  }

  Future<void> updateIncome(IncomeEntry entry) async {
    try {
      await _requireBox.put(entry.id, entry);
    } catch (e) {
      throw IncomeDatabaseException('Failed to update income: $e');
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      await _requireBox.delete(id);
    } catch (e) {
      throw IncomeDatabaseException('Failed to delete income: $e');
    }
  }

  double getTotalIncome() {
    try {
      return _requireBox.values.fold(0.0, (sum, e) => sum + e.amount);
    } catch (e) {
      throw IncomeDatabaseException('Failed to calculate total income: $e');
    }
  }
}