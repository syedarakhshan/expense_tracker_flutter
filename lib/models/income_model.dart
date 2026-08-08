import 'package:hive/hive.dart';

part 'income_model.g.dart';

/// A single income record — e.g. one student's tuition fee payment.
/// typeId: 1 — must be unique across all Hive models (Expense already uses 0).
@HiveType(typeId: 1)
class IncomeEntry extends HiveObject {
  @HiveField(0)
  final String id;

  /// Who paid — e.g. the student's name. Kept as a plain string (not a
  /// separate Student model) since you're not managing student profiles,
  /// just labeling each payment.
  @HiveField(1)
  final String studentName;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String notes;

  @HiveField(5)
  final DateTime createdAt;

  IncomeEntry({
    required this.id,
    required this.studentName,
    required this.amount,
    required this.date,
    this.notes = '',
    required this.createdAt,
  });

  IncomeEntry copyWith({
    String? studentName,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return IncomeEntry(
      id: id,
      studentName: studentName ?? this.studentName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}