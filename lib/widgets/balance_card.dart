import 'package:flutter/material.dart';
import 'animated_currency_text.dart';

/// The prominent card at the top of Home showing total balance,
/// with income and expense broken out side-by-side beneath it.
class BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String currencyCode;
  final VoidCallback? onEditIncome;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    this.currencyCode = 'USD',
    this.onEditIncome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedCurrencyText(
            amount: balance,
            currencyCode: currencyCode,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Income tile — tappable, shows edit pencil
              Expanded(
                child: GestureDetector(
                  onTap: onEditIncome,
                  child: _SummaryTile(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    amount: income,
                    color: Colors.greenAccent.shade100,
                    onPrimary: theme.colorScheme.onPrimary,
                    currencyCode: currencyCode,
                    editable: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Expense tile — NOT tappable, no pencil, shows totalExpense
              Expanded(
                child: _SummaryTile(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Expense',
                  amount: expense,
                  color: Colors.redAccent.shade100,
                  onPrimary: theme.colorScheme.onPrimary,
                  currencyCode: currencyCode,
                  editable: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final Color onPrimary;
  final String currencyCode;
  final bool editable;

  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.onPrimary,
    required this.currencyCode,
    this.editable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: onPrimary.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
              if (editable) ...[
                const SizedBox(width: 4),
                Icon(Icons.edit, size: 12, color: onPrimary.withValues(alpha: 0.6)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          AnimatedCurrencyText(
            amount: amount,
            currencyCode: currencyCode,
            style: TextStyle(
              color: onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}