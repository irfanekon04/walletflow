import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/features/dashboard/presentation/widgets/accounts_section.dart';
import 'package:walletflow/features/dashboard/presentation/widgets/budget_overview_section.dart';
import 'package:walletflow/features/dashboard/presentation/widgets/income_expense_summary.dart';
import 'package:walletflow/features/dashboard/presentation/widgets/loan_summary_section.dart';
import 'package:walletflow/features/dashboard/presentation/widgets/recent_transactions_section.dart';
import 'package:walletflow/features/dashboard/presentation/widgets/top_spending_card.dart';
import 'package:walletflow/features/dashboard/presentation/widgets/total_balance_card.dart';
import 'package:walletflow/features/reports/presentation/pages/reports_page.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../../../budgets/presentation/controllers/budget_controller.dart';
import '../../../loans/presentation/controllers/loan_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final transactionController = Get.find<TransactionController>();
    final budgetController = Get.find<BudgetController>();
    final loanController = Get.find<LoanController>();

    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Get.to(() => const ReportsPage()),
            tooltip: 'Financial Reports',
          ),
          IconButton(icon: const Icon(Icons.sync_outlined), onPressed: () {}),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          accountController.loadAccounts();
          transactionController.loadTransactions();
          budgetController.loadBudgets();
          loanController.loadLoans();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(context.responsivePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => TotalBalanceCard(
                  balance: currencyFormat.format(
                    accountController.totalBalance.value,
                  ),
                ),
              ),
              SizedBox(height: context.responsiveHeight(0.02)),
              Obx(
                () => IncomeExpenseSummary(
                  income: currencyFormat.format(
                    transactionController.totalIncome.value,
                  ),
                  expense: currencyFormat.format(
                    transactionController.totalExpense.value,
                  ),
                ),
              ),
              Obx(() {
                if (transactionController.topSpendingCategory.value == null ||
                    transactionController.topSpendingAmount.value <= 0) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    SizedBox(height: context.responsiveHeight(0.03)),
                    TopSpendingCard(
                      controller: transactionController,
                      format: currencyFormat,
                    ),
                  ],
                );
              }),
              SizedBox(height: context.responsiveHeight(0.02)),
              AccountsSection(
                controller: accountController,
                format: currencyFormat,
              ),
              SizedBox(height: context.responsiveHeight(0.02)),
              RecentTransactionsSection(
                controller: transactionController,
                format: currencyFormat,
              ),
              SizedBox(height: context.responsiveHeight(0.02)),
              BudgetOverviewSection(
                controller: budgetController,
                format: currencyFormat,
              ),
              SizedBox(height: context.responsiveHeight(0.02)),
              LoanSummarySection(
                controller: loanController,
                format: currencyFormat,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
