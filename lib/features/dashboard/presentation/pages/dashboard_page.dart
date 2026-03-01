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

    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appName, style: theme.textTheme.titleLarge),
        actions: [
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
                () => _buildBalanceCard(
                  context,
                  currencyFormat.format(accountController.totalBalance.value),
                ),
              ),
              SizedBox(height: context.responsiveHeight(0.02)),
              _buildThisMonthSummary(
                context,
                currencyFormat.format(transactionController.totalIncome.value),
                currencyFormat.format(transactionController.totalExpense.value),
              ),
              SizedBox(height: context.responsiveHeight(0.03)),
              _buildAccountsSection(context, accountController, currencyFormat),
              SizedBox(height: context.responsiveHeight(0.03)),
              _buildRecentTransactions(
                context,
                transactionController,
                currencyFormat,
              ),
              SizedBox(height: context.responsiveHeight(0.03)),
              _buildBudgetOverview(context, budgetController, currencyFormat),
              SizedBox(height: context.responsiveHeight(0.03)),
              _buildLoanSummary(context, loanController, currencyFormat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, String balance) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.responsivePadding * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.totalBalance,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.7,
                ),
                fontSize: 14 * context.responsiveFontSize,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.01)),
            Text(
              balance,
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontSize: 32 * context.responsiveFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThisMonthSummary(
    BuildContext context,
    String income,
    String expense,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        color: theme.colorScheme.primary,
                        size: 18 * context.responsiveFontSize,
                      ),
                      SizedBox(width: context.responsiveWidth(0.01)),
                      Text(
                        AppStrings.income,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    income,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: context.responsiveWidth(0.03)),
        Expanded(
          child: Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_upward,
                        color: theme.colorScheme.error,
                        size: 18 * context.responsiveFontSize,
                      ),
                      SizedBox(width: context.responsiveWidth(0.01)),
                      Text(
                        AppStrings.expense,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    expense,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppStrings.accounts,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.accounts.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    AppStrings.noAccounts,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            height: context.responsiveHeight(0.14),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: controller.accounts.length,
              itemBuilder: (context, index) {
                final account = controller.accounts[index];
                return Card(
                  margin: EdgeInsets.only(right: context.responsiveWidth(0.03)),
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Container(
                    width: context.isTabletWidth ? 200 : 160,
                    padding: EdgeInsets.all(context.responsivePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getAccountIcon(account.type.name),
                              size: 20 * context.responsiveFontSize,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: context.responsiveWidth(0.02)),
                            Expanded(
                              child: Text(
                                account.name,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          format.format(account.balance),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20 * context.responsiveFontSize,
                            color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final transactions = controller.transactions.take(5).toList();
          if (transactions.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    AppStrings.noTransactions,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }
          return Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 72,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final category = controller.getCategoryById(
                  transaction.categoryId ?? '',
                );
                final color = category != null
                    ? Color(
                        int.parse(
                          category.color.replaceFirst('#', 'FF'),
                          radix: 16,
                        ),
                      )
                    : theme.colorScheme.secondary;

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCategoryIcon(category?.icon ?? 'category'),
                      color: color,
                      size: 20 * context.responsiveFontSize,
                    ),
                  ),
                  title: Text(
                    category?.name ?? 'Uncategorized',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Text(
                    '${transaction.type == TransactionType.expense ? '-' : '+'}${format.format(transaction.amount)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.expense
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Budget Overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.budgets.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    AppStrings.noBudgets,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }
          final percent = controller.totalBudget.value > 0
              ? controller.totalSpent.value / controller.totalBudget.value
              : 0.0;
          final isOver =
              controller.totalSpent.value > controller.totalBudget.value;

          return Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${controller.getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}',
                        style: theme.textTheme.labelLarge,
                      ),
                      Text(
                        '${format.format(controller.totalSpent.value)} / ${format.format(controller.totalBudget.value)}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isOver
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      minHeight: 8 * context.responsiveFontSize,
                      backgroundColor: theme.colorScheme.onSurface.withValues(
                        alpha: .3,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isOver
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Loan Summary',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: Card(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.lent,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * context.responsiveFontSize,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          format.format(controller.totalLent.value),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                            fontSize: 20 * context.responsiveFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: theme.colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.owed,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * context.responsiveFontSize,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          format.format(controller.totalOwed.value),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                            fontSize: 20 * context.responsiveFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.account_balance_wallet_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'mfs':
        return Icons.phone_android_outlined;
      case 'creditCard':
        return Icons.credit_card_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }

  IconData _getCategoryIcon(String icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.category_outlined;
    }
  }
}
