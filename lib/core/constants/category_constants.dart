import 'package:flutter/material.dart';

/// Defines a single expense category: its label, icon, and color.
/// Using a class instead of a plain enum lets us attach UI metadata
/// (icon + color) directly to each category.
class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Central registry of all supported expense categories.
/// Adding a new category only requires adding one entry here —
/// every screen (Add Expense, Statistics, Filters) reads from this list.
class CategoryConstants {
  CategoryConstants._();
  static const List<ExpenseCategory> incomeCategories = [
    ExpenseCategory(name: 'Salary', icon: Icons.work_outline, color: Color(0xFF00B894)),
    ExpenseCategory(name: 'Freelance', icon: Icons.laptop_mac, color: Color(0xFF0984E3)),
    ExpenseCategory(name: 'Gift', icon: Icons.card_giftcard, color: Color(0xFFE84393)),
    ExpenseCategory(name: 'Investment', icon: Icons.trending_up, color: Color(0xFF6C5CE7)),
    ExpenseCategory(name: 'Other Income', icon: Icons.attach_money, color: Color(0xFF95A5A6)),
  ];

  static const List<ExpenseCategory> categories = [
    ExpenseCategory(name: 'Food', icon: Icons.restaurant, color: Color(0xFFFF6B6B)),
    ExpenseCategory(name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFF4ECDC4)),
    ExpenseCategory(name: 'Transport', icon: Icons.directions_car, color: Color(0xFFFFD93D)),
    ExpenseCategory(name: 'Bills', icon: Icons.receipt_long, color: Color(0xFF6C5CE7)),
    ExpenseCategory(name: 'Education', icon: Icons.school, color: Color(0xFF00B894)),
    ExpenseCategory(name: 'Medical', icon: Icons.local_hospital, color: Color(0xFFE84393)),
    ExpenseCategory(name: 'Entertainment', icon: Icons.movie, color: Color(0xFFFF8C42)),
    ExpenseCategory(name: 'Travel', icon: Icons.flight, color: Color(0xFF0984E3)),
    ExpenseCategory(name: 'Other', icon: Icons.category, color: Color(0xFF95A5A6)),
  ];

  /// Get category names only (used for dropdowns, filters)
  static List<String> get categoryNames =>
      categories.map((c) => c.name).toList();

  /// Look up a full ExpenseCategory object by its name, searching BOTH
  /// expense and income category lists — needed since a single Expense
  /// record's category could belong to either set depending on its `type`.
  /// Falls back to "Other" if the name isn't recognized —
  /// protects against corrupted/legacy data in Hive.
  static ExpenseCategory getCategoryByName(String name) {
    final all = [...categories, ...incomeCategories];
    return all.firstWhere(
          (c) => c.name == name,
      orElse: () => categories.last,
    );
  }
}