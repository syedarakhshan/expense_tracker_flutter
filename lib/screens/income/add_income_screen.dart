import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

import '../../core/utils/date_formatter.dart';
import '../../providers/income_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class AddIncomeScreen extends ConsumerStatefulWidget {
  final String? incomeId;

  const AddIncomeScreen({super.key, this.incomeId});

  @override
  ConsumerState<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends ConsumerState<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  bool get _isEditing => widget.incomeId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final entries = ref.read(incomeListProvider);
      final existing = entries.where((e) => e.id == widget.incomeId).firstOrNull;
      if (existing != null) {
        _studentController.text = existing.studentName;
        _amountController.text = existing.amount.toString();
        _notesController.text = existing.notes;
        _selectedDate = existing.date;
      }
    }
  }

  @override
  void dispose() {
    _studentController.dispose();
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final studentName = _studentController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final notes = _notesController.text.trim();

    try {
      if (_isEditing) {
        final entries = ref.read(incomeListProvider);
        final existing = entries.where((e) => e.id == widget.incomeId).firstOrNull;
        if (existing != null) {
          final updated = existing.copyWith(
            studentName: studentName,
            amount: amount,
            date: _selectedDate,
            notes: notes,
          );
          await ref.read(incomeListProvider.notifier).updateIncome(updated);
        }
      } else {
        await ref.read(incomeListProvider.notifier).addIncome(
          studentName: studentName,
          amount: amount,
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
        title: Text(_isEditing ? 'Edit Payment' : 'Add Fee Payment'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextField(
                controller: _studentController,
                label: 'Student Name',
                hint: 'e.g. Ahmed Khan',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Student name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _amountController,
                label: 'Amount Received',
                hint: '0.00',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed <= 0) return 'Amount must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Date', style: Theme.of(context).textTheme.titleSmall),
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
              CustomTextField(
                controller: _notesController,
                label: 'Notes (optional)',
                hint: 'e.g. Paid for June + July',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: _isEditing ? 'Update Payment' : 'Save Payment',
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