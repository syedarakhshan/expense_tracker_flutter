import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/section_title.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  Future<void> _showEditIncomeDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: ref.read(manualIncomeProvider) == 0
          ? ''
          : ref.read(manualIncomeProvider).toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Income'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.attach_money),
            hintText: '0.00',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 0) {
                Navigator.of(context).pop(parsed);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await ref.read(manualIncomeProvider.notifier).setIncome(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionTitle(title: 'Appearance'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: themeMode == ThemeMode.dark,
              onChanged: (value) =>
                  ref.read(themeModeProvider.notifier).toggle(value),
            ),
          ),

          const SizedBox(height: 24),

          const SectionTitle(title: 'Currency'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Currency'),
              subtitle: Text(currency),
              trailing: DropdownButton<String>(
                value: currency,
                underline: const SizedBox.shrink(),
                items: AppConstants.supportedCurrencies
                    .map((code) => DropdownMenuItem(
                  value: code,
                  child: Text(code),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(currencyProvider.notifier).setCurrency(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 24),

          const SectionTitle(title: 'Income'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money_rounded),
              title: const Text('Monthly Income'),
              subtitle: Text(CurrencyFormatter.format(
                ref.watch(manualIncomeProvider),
                currencyCode: currency,
              )),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _showEditIncomeDialog(context, ref),
            ),
          ),

          const SectionTitle(title: 'About'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Expense Tracker'),
              subtitle: const Text('Version ${AppConstants.appVersion}'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationIcon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                children: const [
                  SizedBox(height: 12),
                  Text(
                    'A simple, offline-first expense tracker built with '
                        'Flutter, Riverpod, and Hive.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}