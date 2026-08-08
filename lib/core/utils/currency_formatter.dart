import 'package:intl/intl.dart';

/// Formats numeric amounts as currency strings using `intl`.
/// Currently defaults to USD; Step 13 (Settings) will make the
/// currency user-selectable and this will read from a provider.
class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String currencyCode = 'USD'}) {
    final formatter = NumberFormat.simpleCurrency(name: currencyCode);
    return formatter.format(amount);
  }
}