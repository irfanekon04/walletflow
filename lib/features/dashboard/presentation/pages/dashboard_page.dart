import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';
import '../../../budgets/presentation/controllers/budget_controller.dart';
import '../../../loans/presentation/controllers/loan_controller.dart';
import '../../../transactions/data/models/transaction_model.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final transactionController = Get.find<TransactionController>();
    final budgetController = Get.find<BudgetController>();
    final loanController = Get.find<LoanController>();
    
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {},
          ),
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
              Obx(() => _buildBalanceCard(
                context,
                currencyFormat.format(accountController.totalBalance.value),
              )),
              const SizedBox(height: AppDimensions.paddingM),
              _buildThisMonthSummary(
                context,
                currencyFormat.format(transactionController.totalIncome.value),
                currencyFormat.format(transactionController.totalExpense.value),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              _buildAccountsSection(context, accountController, currencyFormat),
              const SizedBox(height: AppDimensions.paddingL),
              _buildRecentTransactions(context, transactionController, currencyFormat),
              const SizedBox(height: AppDimensions.paddingL),
              _buildBudgetOverview(context, budgetController, currencyFormat),
              const SizedBox(height: AppDimensions.paddingL),
              _buildLoanSummary(context, loanController, currencyFormat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, String balance) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.totalBalance,
              style: TextStyle(
                fontSize: 14 * context.responsiveFontSize,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            Text(
              balance,
              style: TextStyle(
                fontSize: 32 * context.responsiveFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThisMonthSummary(BuildContext context, String income, String expense) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_downward, color: AppColors.incomeGreen, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.income,
                        style: TextStyle(
                          fontSize: 12 * context.responsiveFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    income,
                    style: TextStyle(
                      fontSize: 18 * context.responsiveFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.incomeGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingM),
        Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_upward, color: AppColors.expenseRed, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.expense,
                        style: TextStyle(
                          fontSize: 12 * context.responsiveFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense,
                    style: TextStyle(
                      fontSize: 18 * context.responsiveFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.expenseRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountsSection(
    BuildContext context,
    AccountController controller,
    NumberFormat format,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.accounts,
          style: TextStyle(
            fontSize: 18 * context.responsiveFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Obx(() {
          if (controller.accounts.isEmpty) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: Center(
                  child: Text(
                    AppStrings.noAccounts,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.accounts.length,
              itemBuilder: (context, index) {
                final account = controller.accounts[index];
                return Card(
                  margin: const EdgeInsets.only(right: AppDimensions.paddingS),
                  child: Container(
                    width: context.screenWidth * 0.4,
                    padding: EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getAccountIcon(account.type.name),
                              color: AppColors.fromHex(account.color),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                account.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14 * context.responsiveFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          format.format(account.balance),
                          style: TextStyle(
                            fontSize: 16 * context.responsiveFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    TransactionController controller,
    NumberFormat format,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18 * context.responsiveFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Obx(() {
          final transactions = controller.transactions.take(5).toList();
          if (transactions.isEmpty) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: Center(
                  child: Text(
                    AppStrings.noTransactions,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            );
          }
          return Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final category = controller.getCategoryById(transaction.categoryId ?? '');
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.fromHex(category?.color ?? '#607D8B'),
                    child: Icon(
                      _getCategoryIcon(category?.icon ?? 'category'),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    category?.name ?? 'Uncategorized',
                    style: TextStyle(
                      fontSize: 14 * context.responsiveFontSize,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: TextStyle(
                      fontSize: 12 * context.responsiveFontSize,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Text(
                    '${transaction.type == TransactionType.expense ? '-' : '+'}${format.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 14 * context.responsiveFontSize,
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.expense
                          ? AppColors.expenseRed
                          : AppColors.incomeGreen,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBudgetOverview(
    BuildContext context,
    BudgetController controller,
    NumberFormat format,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Overview',
          style: TextStyle(
            fontSize: 18 * context.responsiveFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Obx(() {
          if (controller.budgets.isEmpty) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingL),
                child: Center(
                  child: Text(
                    AppStrings.noBudgets,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            );
          }
          return Card(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${controller.getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}'),
                      Text('${format.format(controller.totalSpent.value)} / ${format.format(controller.totalBudget.value)}'),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  LinearProgressIndicator(
                    value: controller.totalBudget.value > 0
                        ? controller.totalSpent.value / controller.totalBudget.value
                        : 0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      controller.totalSpent.value > controller.totalBudget.value
                          ? AppColors.expenseRed
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoanSummary(
    BuildContext context,
    LoanController controller,
    NumberFormat format,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loan Summary',
          style: TextStyle(
            fontSize: 18 * context.responsiveFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingS),
        Obx(() => Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.lent,
                        style: TextStyle(
                          fontSize: 12 * context.responsiveFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        format.format(controller.totalLent.value),
                        style: TextStyle(
                          fontSize: 16 * context.responsiveFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.incomeGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.owed,
                        style: TextStyle(
                          fontSize: 12 * context.responsiveFontSize,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        format.format(controller.totalOwed.value),
                        style: TextStyle(
                          fontSize: 16 * context.responsiveFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expenseRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.wallet;
      case 'bank':
        return Icons.account_balance;
      case 'mfs':
        return Icons.phone_android;
      case 'creditCard':
        return Icons.credit_card;
      default:
        return Icons.wallet;
    }
  }

  IconData _getCategoryIcon(String icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}
