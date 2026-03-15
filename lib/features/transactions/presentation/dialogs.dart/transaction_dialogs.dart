import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/core/widgets/app_button.dart';
import 'package:walletflow/core/widgets/confirm_dialog.dart';

import 'package:walletflow/features/accounts/presentation/controllers/account_controller.dart';
import 'package:walletflow/features/transactions/data/models/category_model.dart';
import 'package:walletflow/features/transactions/data/models/transaction_model.dart';
import 'package:walletflow/features/transactions/presentation/controllers/transaction_controller.dart';
import 'package:walletflow/features/transactions/presentation/widgets/add_transaction_form_widget.dart';

class TransactionDialogs {
  static void showFilterBottomSheet(
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
                  child: AppButton(
                    isOutlined: true,
                    label: 'Clear',
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                  ),
                ),
                SizedBox(width: context.responsiveWidth(0.03)),
                Expanded(
                  child: AppButton(label: 'Apply', onPressed: () => Get.back()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showAddTransactionBottomSheet(BuildContext context) {
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

  static void showTransactionDetails(
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
              showDeleteConfirmation(context, transaction);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              showEditTransactionBottomSheet(
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

  static Future<void> showDeleteConfirmation(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final controller = Get.find<TransactionController>();

    final confirmed = await ConfirmDialog.show(
      title: 'Delete Transaction',
      message:
          'Are you sure you want to delete this transaction? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true) {
      await controller.deleteTransactionAndAdjustBalance(transaction);
    }
  }

  static void showEditTransactionBottomSheet(
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
