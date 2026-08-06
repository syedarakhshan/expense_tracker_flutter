import 'package:flutter/material.dart';

/// Placeholder — full implementation arrives in Step 8.
/// [expenseId] will be non-null when this screen is used for editing
/// an existing expense (Step 10), null when adding a new one.
class AddExpenseScreen extends StatelessWidget {
  final String? expenseId;

  const AddExpenseScreen({super.key, this.expenseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(expenseId == null ? 'Add Expense' : 'Edit Expense'),
      ),
    );
  }
}