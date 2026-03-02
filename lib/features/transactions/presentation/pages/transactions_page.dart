import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_filter_tabs.dart';
import '../widgets/add_transaction_form_widget.dart';
import '../widgets/transfer_list_item.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    final accountController = Get.find<AccountController>();
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.transactions, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () =>
                _showFilterBottomSheet(context, controller, accountController),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(
            () => TransactionFilterTabs(
              selectedType: controller.filterType.value,
              onTypeSelected: (type) {
                controller.filterType.value = type;
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              final filteredTransactions = controller.getFilteredTransactions();

              if (filteredTransactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64 * context.responsiveFontSize,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      SizedBox(height: context.responsiveHeight(0.02)),
                      Text(
                        AppStrings.noTransactions,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.only(
                  top: AppDimensions.paddingS,
                  left: context.responsivePadding,
                  right: context.responsivePadding,
                  bottom: 120,
                ),
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = filteredTransactions[index];

                  if (transaction.type == TransactionType.transfer) {
                    return TransferListItem(
                      transaction: transaction,
                      onTap: () => _showEditTransactionBottomSheet(
                        context,
                        controller,
                        accountController,
                        transaction,
                      ),
                      onDelete: () =>
                          _showDeleteConfirmation(context, transaction),
                    );
                  }

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

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: theme.colorScheme.surfaceContainerLow,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          controller.getCategoryIcon(
                            category?.icon ?? 'category',
                          ),
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
                        '${DateFormat('MMM dd, yyyy').format(transaction.date)}${transaction.note != null ? ' - ${transaction.note}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        '${transaction.type == TransactionType.expense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: transaction.type == TransactionType.expense
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      onTap: () => _showTransactionDetails(
                        context,
                        transaction,
                        category,
                        currencyFormat,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'transactions_fab',
        onPressed: () => _showAddTransactionBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    TransactionController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(
        () => Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: controller.filterType.value == null,
              onSelected: (_) => controller.filterType.value = null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.income),
              selected: controller.filterType.value == TransactionType.income,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.income,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.expense),
              selected: controller.filterType.value == TransactionType.expense,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.expense,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.transfer),
              selected: controller.filterType.value == TransactionType.transfer,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.transfer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    TransactionController controller,
    AccountController accountController,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Account', style: theme.textTheme.titleLarge),
            SizedBox(height: context.responsiveHeight(0.02)),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: controller.filterAccountId.value.isEmpty,
                    onSelected: (_) => controller.filterAccountId.value = '',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  ...accountController.accounts.map(
                    (acc) => ChoiceChip(
                      label: Text(acc.name),
                      selected: controller.filterAccountId.value == acc.id,
                      onSelected: (_) =>
                          controller.filterAccountId.value = acc.id,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.04)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    child: const Text('Clear'),
                  ),
                ),
                SizedBox(width: context.responsiveWidth(0.03)),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Get.back(),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => AddTransactionFormWidget(
        onSaved: () {
          Get.find<TransactionController>().loadTransactions();
          Get.find<AccountController>().loadAccounts();
        },
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    CategoryModel? category,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category?.name ?? 'Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${transaction.type == TransactionType.expense ? '-' : '+'}${format.format(transaction.amount)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: transaction.type == TransactionType.expense
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.01)),
            Text(
              'Date: ${DateFormat('MMMM dd, yyyy').format(transaction.date)}',
            ),
            if (transaction.note != null) ...[
              SizedBox(height: context.responsiveHeight(0.01)),
              Text('Note: ${transaction.note}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _showDeleteConfirmation(context, transaction);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showEditTransactionBottomSheet(
                context,
                Get.find<TransactionController>(),
                Get.find<AccountController>(),
                transaction,
              );
            },
            child: const Text('Edit'),
          ),
          FilledButton.tonal(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await controller.deleteTransaction(transaction.id);

              final accountController = Get.find<AccountController>();
              if (transaction.type == TransactionType.expense) {
                await accountController.updateBalance(
                  transaction.accountId,
                  transaction.amount,
                  isAdd: true,
                );
              } else if (transaction.type == TransactionType.income) {
                await accountController.updateBalance(
                  transaction.accountId,
                  transaction.amount,
                  isAdd: false,
                );
              } else if (transaction.type == TransactionType.transfer &&
                  transaction.toAccountId != null) {
                await accountController.updateBalance(
                  transaction.accountId,
                  transaction.amount,
                  isAdd: true,
                );
                await accountController.updateBalance(
                  transaction.toAccountId!,
                  transaction.amount,
                  isAdd: false,
                );
              }
              accountController.loadAccounts();
              if (context.mounted) Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditTransactionBottomSheet(
    BuildContext context,
    TransactionController controller,
    AccountController accountController,
    TransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => AddTransactionFormWidget(
        existingTransaction: transaction,
        onSaved: () {
          controller.loadTransactions();
          accountController.loadAccounts();
        },
      ),
    );
  }
}
