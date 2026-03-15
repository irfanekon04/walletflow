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
import '../../../../core/widgets/empty_state_widget.dart';

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

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    if (dateOnly.isAfter(today.subtract(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(date);
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

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
            final flatList = controller.flattenedTransactions;

            if (flatList.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.receipt_long_outlined,
                title: AppStrings.noTransactions,
                subtitle: 'No transactions found for the selected filters.',
                // actionLabel: 'Clear Filters',
                // onAction: () => controller.clearFilters(),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.only(
                top: 8.r,
                left: 16.r,
                right: 16.r,
                bottom: 120.h,
              ),
              itemCount: flatList.length,
              itemBuilder: (context, index) {
                final item = flatList[index];

                if (item is DateTime) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12.h,
                    ),
                    child: Text(
                      _formatDateHeader(item),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                final transaction = item as TransactionModel;

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
                  margin: EdgeInsets.only(
                    bottom: 12.h,
                  ),
                  color: theme.colorScheme.surfaceContainerLow,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.r,
                      vertical: 8.h,
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        controller.getCategoryIcon(
                          category?.icon ?? 'category',
                        ),
                        color: color,
                        size: 20.sp,
                      ),
                    ),
                    title: Text(
                      category?.name ?? 'Uncategorized',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    subtitle: Text(
                      transaction.note ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${transaction.type == TransactionType.expense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: transaction.type == TransactionType.expense
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        fontSize: 16.sp,
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
