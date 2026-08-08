import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../core/constants/category_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Handles both "Add" and "Edit" flows for an expense.
/// If [expenseId] is provided, the form is pre-filled with that expense's
/// data and submitting calls `updateExpense` instead of `addExpense`.
class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? expenseId;

  const AddExpenseScreen({super.key, this.expenseId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _prefillForEdit();
    }
  }

  /// Loads the existing expense's values into the form fields.
  void _prefillForEdit() {
    final expenses = ref.read(expenseListProvider);
    final existing = expenses.where((e) => e.id == widget.expenseId).firstOrNull;

    if (existing != null) {
      _titleController.text = existing.title;
      _amountController.text = existing.amount.toString();
      _notesController.text = existing.notes;
      _selectedCategory = existing.category;
      _selectedDate = existing.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    // Category isn't part of Form validation (it's not a TextFormField),
    // so we check it separately and surface a SnackBar if missing.
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final notes = _notesController.text.trim();

    try {
      if (_isEditing) {
        final expenses = ref.read(expenseListProvider);
        final existing =
            expenses.where((e) => e.id == widget.expenseId).firstOrNull;
        if (existing != null) {
          final updated = existing.copyWith(
            title: title,
            amount: amount,
            category: _selectedCategory,
            date: _selectedDate,
            notes: notes,
          );
          await ref.read(expenseListProvider.notifier).updateExpense(updated);
        }
      } else {
        await ref.read(expenseListProvider.notifier).addExpense(
          title: title,
          amount: amount,
          category: _selectedCategory!,
          date: _selectedDate,
          notes: notes,
        );
      }

      if (!mounted) return;
      context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g. Grocery shopping',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              CustomTextField(
                controller: _amountController,
                label: 'Amount',
                hint: '0.00',
                prefixIcon: Icons.attach_money,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null) {
                    return 'Enter a valid number';
                  }
                  if (parsed <= 0) {
                    return 'Amount must be greater than zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category
              Text(
                'Category',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: CategoryConstants.categories.map((cat) {
                  return CategoryChipWidget(
                    category: cat,
                    isSelected: _selectedCategory == cat.name,
                    onTap: () => setState(() => _selectedCategory = cat.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Date picker
              Text(
                'Date',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormatter.formatMedium(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              CustomTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'Add any extra details...',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save button
              PrimaryButton(
                label: _isEditing ? 'Update Expense' : 'Save Expense',
                icon: Icons.check,
                isLoading: _isSaving,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}