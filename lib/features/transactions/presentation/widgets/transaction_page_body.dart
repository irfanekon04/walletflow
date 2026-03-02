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

  Map<String, List<TransactionModel>> _groupTransactionsByDate(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }
    
    return grouped;
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
            // First get filtered transactions, then group by date
            final filteredTransactions = controller.getFilteredTransactions();
            final groupedTransactions = _groupTransactionsByDate(filteredTransactions);
            
            if (groupedTransactions.isEmpty) {
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

            final sortedDates = groupedTransactions.keys.toList()
              ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

            return ListView.builder(
              padding: EdgeInsets.only(
                top: AppDimensions.paddingS,
                left: context.responsivePadding,
                right: context.responsivePadding,
                bottom: 120,
              ),
              itemCount: sortedDates.length,
              itemBuilder: (context, index) {
                final dateKey = sortedDates[index];
                final transactions = groupedTransactions[dateKey]!;
                final date = DateTime.parse(dateKey);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _formatDateHeader(date),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    ...transactions.map((transaction) {
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
                            transaction.note ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
                    }),
                  ],
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
