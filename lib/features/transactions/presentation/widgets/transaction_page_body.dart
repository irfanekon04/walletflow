import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/features/accounts/presentation/controllers/account_controller.dart';
import 'package:walletflow/features/transactions/data/models/transaction_model.dart';
import 'package:walletflow/features/transactions/presentation/controllers/transaction_controller.dart';
import 'package:walletflow/features/transactions/presentation/dialogs.dart/transaction_dialogs.dart';
import 'package:walletflow/features/transactions/presentation/widgets/transaction_filter_tabs.dart';
import 'package:walletflow/features/transactions/presentation/widgets/transfer_list_item.dart';

class TransactionPageBody extends StatelessWidget {
  const TransactionPageBody({
    super.key,
    required this.controller,
    required this.theme,
    required this.accountController,
    required this.currencyFormat,
  });

  final TransactionController controller;
  final ThemeData theme;
  final AccountController accountController;
  final NumberFormat currencyFormat;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    onTap: () =>
                        TransactionDialogs.showEditTransactionBottomSheet(
                          context,
                          controller,
                          accountController,
                          transaction,
                        ),
                    onDelete: () => TransactionDialogs.showDeleteConfirmation(
                      context,
                      transaction,
                    ),
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
                    onTap: () => TransactionDialogs.showTransactionDetails(
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
    );
  }
}
