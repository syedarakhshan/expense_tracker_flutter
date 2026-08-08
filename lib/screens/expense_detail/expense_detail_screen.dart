import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:collection/collection.dart';
import '../../core/constants/category_constants.dart';
import '../../core/constants/route_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_widget.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);
    final expense = expenses.where((e) => e.id == expenseId).firstOrNull;

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Expense Detail')),
        body: const EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: 'Expense Not Found',
          message: 'This expense may have been deleted.',
        ),
      );
    }

    final category = CategoryConstants.getCategoryByName(expense.category);
    final theme = Theme.of(context);
    final currencyCode = ref.watch(currencyProvider); // ← lives here, inside build()

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () =>
                context.push('${RouteConstants.editExpense}/${expense.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _handleDelete(context, ref, expense.id, expense.title),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(category.icon, color: category.color, size: 34),
                ),
                const SizedBox(height: 16),
                Text(
                  '-${CurrencyFormatter.format(expense.amount, currencyCode: currencyCode)}', // ← used here
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.title,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: expense.category,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: DateFormatter.formatMedium(expense.date),
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Added On',
                    value: DateFormatter.formatMedium(expense.createdAt),
                  ),
                  if (expense.notes.trim().isNotEmpty) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      icon: Icons.notes,
                      label: 'Notes',
                      value: expense.notes,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(
      BuildContext context,
      WidgetRef ref,
      String id,
      String title,
      ) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Expense',
      message: 'Are you sure you want to delete "$title"? This action cannot be undone.',
    );

    if (confirmed != true) return;

    await ref.read(expenseListProvider.notifier).deleteExpense(id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$title" deleted')),
    );
    context.pop();
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}