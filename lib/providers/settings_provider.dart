import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';

/// Injected from main.dart, same pattern as expenseDatabaseServiceProvider.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError(
    'settingsServiceProvider must be overridden in main.dart '
        'with an already-initialized SettingsService instance.',
  );
});

/// Manages the app's ThemeMode and keeps it in sync with Hive.
/// Initial value is read from Hive when the provider is first created
/// (see the constructor), so the app opens in the user's last-chosen mode.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;

  ThemeModeNotifier(this.ref)
      : super(
    ref.read(settingsServiceProvider).getDarkMode()
        ? ThemeMode.dark
        : ThemeMode.light,
  );

  Future<void> toggle(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    await ref.read(settingsServiceProvider).setDarkMode(isDark);
  }
}

final themeModeProvider =
StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

/// Manages the selected currency code and keeps it in sync with Hive.
class CurrencyNotifier extends StateNotifier<String> {
  final Ref ref;

  CurrencyNotifier(this.ref) : super(ref.read(settingsServiceProvider).getCurrency());

  Future<void> setCurrency(String code) async {
    state = code;
    await ref.read(settingsServiceProvider).setCurrency(code);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  return CurrencyNotifier(ref);
});
/// Manages the user's manually-set income and keeps it in sync with Hive.
class IncomeNotifier extends StateNotifier<double> {
  final Ref ref;

  IncomeNotifier(this.ref) : super(ref.read(settingsServiceProvider).getIncome());

  Future<void> setIncome(double value) async {
    state = value;
    await ref.read(settingsServiceProvider).setIncome(value);
  }
}

final manualIncomeProvider = StateNotifierProvider<IncomeNotifier, double>((ref) {
  return IncomeNotifier(ref);
});