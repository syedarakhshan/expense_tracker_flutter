import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

/// Wraps the Hive settings box — a simple key/value store for
/// user preferences (dark mode, currency, income), separate from the
/// expenses box since it holds unrelated, unstructured data.
class SettingsService {
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.settingsBoxName);
  }

  Box get _requireBox {
    if (_box == null) {
      throw StateError('SettingsService not initialized. Call init() first.');
    }
    return _box!;
  }

  bool getDarkMode() {
    return _requireBox.get(AppConstants.keyDarkMode, defaultValue: false)
    as bool;
  }

  Future<void> setDarkMode(bool value) async {
    await _requireBox.put(AppConstants.keyDarkMode, value);
  }

  String getCurrency() {
    return _requireBox.get(
      AppConstants.keyCurrency,
      defaultValue: AppConstants.defaultCurrency,
    ) as String;
  }

  Future<void> setCurrency(String code) async {
    await _requireBox.put(AppConstants.keyCurrency, code);
  }

  double getIncome() {
    return _requireBox.get(AppConstants.keyManualIncome, defaultValue: 0.0)
    as double;
  }

  Future<void> setIncome(double value) async {
    await _requireBox.put(AppConstants.keyManualIncome, value);
  }
}