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
    required this.context,
    required this.controller,
    required this.format,
  });

  final BuildContext context;
  final TransactionController controller;
  final NumberFormat format;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData getCategoryIcon(String icon) {
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
              TextButton(
                onPressed: () => Get.find<NavigationController>().changePage(1),
                child: const Text('See All'),
              ),
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
                      getCategoryIcon(category?.icon ?? 'category'),
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
