import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/income_model.dart';
import '../services/income_database_service.dart';
import 'income_database_provider.dart';

final incomeErrorProvider = StateProvider<String?>((ref) => null);

class IncomeNotifier extends StateNotifier<List<IncomeEntry>> {
  final Ref ref;

  IncomeNotifier(this.ref) : super([]) {
    _loadIncome();
  }

  void _loadIncome() {
    try {
      final service = ref.read(incomeDatabaseServiceProvider);
      state = service.getAllIncome();
    } on IncomeDatabaseException catch (e) {
      ref.read(incomeErrorProvider.notifier).state = e.message;
    }
  }

  /// Adds a new fee payment. Each call ADDS to the running total —
  /// this is the "add income on top of existing income" behavior.
  Future<void> addIncome({
    required String studentName,
    required double amount,
    required DateTime date,
    String notes = '',
  }) async {
    try {
      final service = ref.read(incomeDatabaseServiceProvider);
      final entry = IncomeEntry(
        id: const Uuid().v4(),
        studentName: studentName,
        amount: amount,
        date: date,
        notes: notes,
        createdAt: DateTime.now(),
      );
      await service.addIncome(entry);
      _loadIncome();
    } on IncomeDatabaseException catch (e) {
      ref.read(incomeErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> updateIncome(IncomeEntry updated) async {
    try {
      final service = ref.read(incomeDatabaseServiceProvider);
      await service.updateIncome(updated);
      _loadIncome();
    } on IncomeDatabaseException catch (e) {
      ref.read(incomeErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      final service = ref.read(incomeDatabaseServiceProvider);
      await service.deleteIncome(id);
      _loadIncome();
    } on IncomeDatabaseException catch (e) {
      ref.read(incomeErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> restoreIncome(IncomeEntry entry) async {
    try {
      final service = ref.read(incomeDatabaseServiceProvider);
      await service.addIncome(entry);
      _loadIncome();
    } on IncomeDatabaseException catch (e) {
      ref.read(incomeErrorProvider.notifier).state = e.message;
    }
  }

  void refresh() => _loadIncome();
}

final incomeListProvider =
StateNotifierProvider<IncomeNotifier, List<IncomeEntry>>((ref) {
  return IncomeNotifier(ref);
});