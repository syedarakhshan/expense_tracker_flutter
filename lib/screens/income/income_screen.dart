import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/income_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_widget.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(incomeListProvider);
    final currencyCode = ref.watch(currencyProvider);
    final total = entries.fold(0.0, (sum, e) => sum + e.amount);
    final theme = Theme.of(context);

    ref.listen<String?>(incomeErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next), backgroundColor: theme.colorScheme.error),
        );
        ref.read(incomeErrorProvider.notifier).state = null;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Income / Fee Payments')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteConstants.addIncome),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total Income',
                  style: TextStyle(color: theme.colorScheme.onPrimary.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(total, currencyCode: currencyCode),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const EmptyStateWidget(
              icon: Icons.school_outlined,
              title: 'No Payments Yet',
              message: 'Tap + to record your first fee payment.',
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
                  ),
                  confirmDismiss: (_) => ConfirmDialog.show(
                    context: context,
                    title: 'Delete Payment',
                    message: 'Delete this payment from ${entry.studentName}?',
                  ),
                  onDismissed: (_) async {
                    await ref.read(incomeListProvider.notifier).deleteIncome(entry.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment from ${entry.studentName} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () =>
                              ref.read(incomeListProvider.notifier).restoreIncome(entry),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () =>
                          context.push('${RouteConstants.editIncome}/${entry.id}'),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                        child: Icon(Icons.person, color: theme.colorScheme.primary),
                      ),
                      title: Text(entry.studentName),
                      subtitle: Text(DateFormatter.formatRelative(entry.date)),
                      trailing: Text(
                        '+${CurrencyFormatter.format(entry.amount, currencyCode: currencyCode)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}