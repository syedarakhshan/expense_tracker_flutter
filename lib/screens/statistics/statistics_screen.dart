import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/category_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/expense_computed_providers.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/section_title.dart';
import '../../providers/settings_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyCode = ref.watch(currencyProvider);
// then update the two CurrencyFormatter.format(...) calls
// (Total Expenses card, and the Category Breakdown list) to pass currencyCode: currencyCode
    final categoryTotals = ref.watch(categoryTotalsProvider);
    final monthlyTotals = ref.watch(monthlyTotalsProvider);
    final totalExpense = ref.watch(totalExpenseProvider);
    final theme = Theme.of(context);

    if (categoryTotals.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistics')),
        body: const EmptyStateWidget(
          icon: Icons.bar_chart_outlined,
          title: 'No Data Yet',
          message: 'Add some expenses to see your spending statistics.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total expenses summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Total Expenses',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(totalExpense, currencyCode: currencyCode), // was: CurrencyFormatter.format(totalExpense)
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pie chart by category
          const SectionTitle(title: 'Spending by Category'),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: categoryTotals.entries.map((entry) {
                  final category = CategoryConstants.getCategoryByName(entry.key);
                  final percentage = (entry.value / totalExpense) * 100;
                  return PieChartSectionData(
                    value: entry.value,
                    color: category.color,
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Category-wise totals list
          const SectionTitle(title: 'Category Breakdown'),
          ...(() {
            // Sort categories by amount spent, highest first.
            final sortedEntries = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return sortedEntries.map((entry) {
              final category = CategoryConstants.getCategoryByName(entry.key);
              final percentage = (entry.value / totalExpense) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(category.icon, size: 18, color: category.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.key, style: theme.textTheme.bodyMedium),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      CurrencyFormatter.format(entry.value),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList();
          })(),
          const SizedBox(height: 24),

          // Monthly bar chart
          const SectionTitle(title: 'Last 6 Months'),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: () {
                  final highest = monthlyTotals
                      .map((m) => m.total)
                      .fold(0.0, (max, v) => v > max ? v : max);
                  // Guard against a degenerate 0-height chart when all
                  // recent months have no spending — give it a sane
                  // minimum scale instead of collapsing to nothing.
                  return highest > 0 ? highest * 1.2 : 100.0;
                }(), // headroom above the tallest bar
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyTotals.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            monthlyTotals[index].label,
                            style: theme.textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: monthlyTotals.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.total,
                        color: theme.colorScheme.primary,
                        width: 22,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}