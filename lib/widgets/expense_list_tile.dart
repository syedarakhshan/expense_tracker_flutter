import 'package:flutter/material.dart';

import '../core/constants/category_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/expense_model.dart';

/// A single row in the expense list — category icon, title, category+date,
/// and amount. Tapping navigates to the Expense Detail screen (wired
/// where this widget is used).
class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final String currencyCode;

  const ExpenseListTile({
    super.key,
    required this.expense,
    required this.onTap,
    this.currencyCode = 'USD',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = CategoryConstants.getCategoryByName(expense.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category icon badge
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 22),
              ),
              const SizedBox(width: 12),

              // Title + category/date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount — green with + for income, red with - for expense
                    Text(
                      '${expense.type == 'income' ? '+' : '-'}${CurrencyFormatter.format(expense.amount, currencyCode: currencyCode)}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: expense.type == 'income'
                            ? Colors.green
                            : theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${expense.category} • ${DateFormatter.formatRelative(expense.date)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Text(
                '-${CurrencyFormatter.format(expense.amount)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}