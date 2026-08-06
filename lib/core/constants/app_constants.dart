/// App-wide constants: names, keys, and Hive box identifiers.
/// Centralizing these avoids "magic strings" scattered across the codebase.
class AppConstants {
  AppConstants._(); // Prevents instantiation

  // App info
  static const String appName = 'Expense Tracker';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String expenseBoxName = 'expenses';
  static const String settingsBoxName = 'settings';

  // Hive settings keys (used inside the settings box)
  static const String keyDarkMode = 'isDarkMode';
  static const String keyCurrency = 'currency';

  // Splash screen delay
  static const Duration splashDuration = Duration(seconds: 2);

  // Default currency (currency code, used with intl's NumberFormat)
  static const String defaultCurrency = 'USD';

  // Supported currencies for Settings screen
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'PKR',
    'INR',
    'JPY',
    'AUD',
    'CAD',
  ];
}