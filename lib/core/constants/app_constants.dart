import 'package:flutter/material.dart';

class AppColors {
  // Light Theme
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF009688);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFB00020);
  static const Color incomeGreen = Color(0xFF4CAF50);
  static const Color expenseRed = Color(0xFFF44336);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF757575);

  // Dark Theme
  static const Color primaryDark = Color(0xFF64B5F6);
  static const Color primaryVariantDark = Color(0xFF42A5F5);
  static const Color secondaryDark = Color(0xFF4DB6AC);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFCF6679);
  static const Color incomeGreenDark = Color(0xFF81C784);
  static const Color expenseRedDark = Color(0xFFE57373);
  static const Color warningOrangeDark = Color(0xFFFFB74D);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color onSurfaceDark = Color(0xFF9E9E9E);

  static Color fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

class AppStrings {
  static const String appName = 'WalletFlow';
  static const String dashboard = 'Dashboard';
  static const String transactions = 'Transactions';
  static const String budgets = 'Budgets';
  static const String loans = 'Loans';
  static const String settings = 'Settings';
  static const String accounts = 'Accounts';
  static const String categories = 'Categories';
  static const String totalBalance = 'Total Balance';
  static const String income = 'Income';
  static const String expense = 'Expense';
  static const String transfer = 'Transfer';
  static const String thisMonth = 'This Month';
  static const String addTransaction = 'Add Transaction';
  static const String addAccount = 'Add Account';
  static const String addBudget = 'Add Budget';
  static const String addLoan = 'Add Loan';
  static const String lent = 'Lent';
  static const String owed = 'Owed';
  static const String noTransactions = 'No transactions yet';
  static const String noAccounts = 'No accounts yet';
  static const String noBudgets = 'No budgets yet';
  static const String noLoans = 'No loans yet';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
}
