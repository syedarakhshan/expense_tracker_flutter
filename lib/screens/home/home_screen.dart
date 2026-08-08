import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/route_constants.dart';
import '../../providers/expense_computed_providers.dart';
import '../../providers/expense_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/active_filters_row.dart';
import '../../widgets/animated_list_item.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/expense_list_tile.dart';
import '../../widgets/search_field.dart';
import '../../widgets/section_title.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAnyExpenses = ref.watch(
      expenseListProvider.select((list) => list.isNotEmpty),
    );
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final balance = ref.watch(balanceProvider);
    final income = ref.watch(totalIncomeProvider);
    final expense = ref.watch(totalExpenseProvider);
    final selectedCategory = ref.watch(selectedCategoryFilterProvider);
    final currencyCode = ref.watch(currencyProvider);

    ref.listen<String?>(expenseErrorProvider, (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(expenseErrorProvider.notifier).state = null;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Statistics',
            onPressed: () => context.push(RouteConstants.statistics),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(RouteConstants.settings),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RouteConstants.addExpense),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(expenseListProvider.notifier).refresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    BalanceCard(
                      balance: balance,
                      income: income,
                      expense: expense,
                      currencyCode: currencyCode,
                      // Tapping Income now opens the full fee-payment ledger
                      // instead of a single-value edit dialog.
                      onEditIncome: () => context.push(RouteConstants.income),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: SearchField()),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.date_range),
                            tooltip: 'Filter by date',
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                                initialDateRange:
                                ref.read(dateRangeFilterProvider),
                              );
                              if (picked != null) {
                                ref.read(dateRangeFilterProvider.notifier).state =
                                    picked;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CategorySelector(
                      selectedCategory: selectedCategory,
                      showAllOption: true,
                      onCategorySelected: (category) => ref
                          .read(selectedCategoryFilterProvider.notifier)
                          .state = category,
                    ),
                    const SizedBox(height: 12),
                    ActiveFiltersRow(
                      selectedCategory: selectedCategory,
                      dateRange: ref.watch(dateRangeFilterProvider),
                      onClearCategory: () => ref
                          .read(selectedCategoryFilterProvider.notifier)
                          .state = null,
                      onClearDateRange: () =>
                      ref.read(dateRangeFilterProvider.notifier).state = null,
                      onClearAll: () {
                        ref.read(selectedCategoryFilterProvider.notifier).state =
                        null;
                        ref.read(dateRangeFilterProvider.notifier).state = null;
                      },
                    ),
                    const SizedBox(height: 8),
                    SectionTitle(
                      title: 'Recent Expenses',
                      trailing: Text(
                        '${filteredExpenses.length} item${filteredExpenses.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!hasAnyExpenses)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 40),
                  child: EmptyStateWidget(
                    title: 'No Expenses Yet',
                    message: 'Tap the + button to add your first expense.',
                  ),
                ),
              )
            else if (filteredExpenses.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 40),
                  child: EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No Matches Found',
                    message: 'Try a different search term or category filter.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final exp = filteredExpenses[index];
                    return AnimatedListItem(
                      index: index,
                      child: Dismissible(
                        key: ValueKey(exp.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        confirmDismiss: (_) => ConfirmDialog.show(
                          context: context,
                          title: 'Delete Expense',
                          message:
                          'Delete "${exp.title}"? This cannot be undone directly, but you can undo from the next screen.',
                        ),
                        onDismissed: (_) async {
                          await ref
                              .read(expenseListProvider.notifier)
                              .deleteExpense(exp.id);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${exp.title}" deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  ref
                                      .read(expenseListProvider.notifier)
                                      .restoreExpense(exp);
                                },
                              ),
                            ),
                          );
                        },
                        child: ExpenseListTile(
                          expense: exp,
                          currencyCode: currencyCode,
                          onTap: () => context
                              .push('${RouteConstants.expenseDetail}/${exp.id}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}