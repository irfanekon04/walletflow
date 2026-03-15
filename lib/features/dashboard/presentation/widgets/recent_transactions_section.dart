import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/app/controllers/navigation_controller.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/features/transactions/data/models/transaction_model.dart';
import 'package:walletflow/features/transactions/presentation/controllers/transaction_controller.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.controller,
    required this.format,
  });

  final TransactionController controller;
  final NumberFormat format;

  @override
  Widget build(BuildContext context) {
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
                  fontSize: (theme.textTheme.headlineSmall?.fontSize ?? 24) *
                      context.responsiveFontSize,
                ),
              ),
              TextButton(
                onPressed: () => Get.find<NavigationController>().changePage(1),
                child: Text(
                  'See All',
                  style: TextStyle(fontSize: 14 * context.responsiveFontSize),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: context.responsiveHeight(0.01)),
        Obx(() {
          final transactions = controller.transactions.take(5).toList();
          if (transactions.isEmpty) {
            return Card(
              color: theme.colorScheme.surfaceContainerLow,
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
                      controller.getCategoryIcon(category?.icon ?? 'category'),
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
}
