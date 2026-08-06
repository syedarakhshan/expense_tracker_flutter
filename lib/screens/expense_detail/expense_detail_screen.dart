import 'package:flutter/material.dart';

/// Placeholder — full implementation arrives in Step 10.
class ExpenseDetailScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Expense Detail: $expenseId')),
    );
  }
}