import 'package:flutter/material.dart';
import '../core/utils/currency_formatter.dart';

/// Animates a currency amount counting up/down to its new value whenever
/// it changes, instead of snapping instantly — used on the Balance Card
/// so adding/deleting an expense feels responsive rather than abrupt.
class AnimatedCurrencyText extends StatelessWidget {
  final double amount;
  final String currencyCode;
  final TextStyle? style;
  final String prefix;

  const AnimatedCurrencyText({
    super.key,
    required this.amount,
    this.currencyCode = 'USD',
    this.style,
    this.prefix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '$prefix${CurrencyFormatter.format(value, currencyCode: currencyCode)}',
          style: style,
        );
      },
    );
  }
}