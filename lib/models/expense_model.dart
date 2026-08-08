import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String notes;

  @HiveField(6)
  final DateTime createdAt;

  /// 'expense' or 'income'. New field — see the adapter note below for
  /// how existing saved records (which predate this field) are handled.
  @HiveField(7)
  final String type;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes = '',
    required this.createdAt,
    this.type = 'expense',
  });

  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    String? type,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      type: type ?? this.type,
    );
  }
}