import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/utils/responsive.dart';
import '../../data/models/budget_model.dart';
import '../../../transactions/data/models/category_model.dart';

class BudgetListItem extends StatelessWidget {
  final BudgetModel budget;
  final CategoryModel? category;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetListItem({
    super.key,
    required this.budget,
    this.category,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spent = budget.spent;
    final limit = budget.amount;
    final percent = limit > 0 ? spent / limit : 0.0;
    final isOver = spent > limit;

    final color = category != null
        ? Color(
            int.parse(
              category!.color.replaceFirst('#', 'FF'),
              radix: 16,
            ),
          )
        : theme.colorScheme.secondary;

    return Card(
      margin: EdgeInsets.only(bottom: context.responsiveHeight(0.02)),
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.all(context.responsivePadding * 1.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsivePadding * 0.6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category?.icon ?? 'category'),
                    color: color,
                    size: 20 * context.responsiveFontSize,
                  ),
                ),
                SizedBox(width: context.responsiveWidth(0.03)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? 'Category',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${currencyFormat.format(spent)} of ${currencyFormat.format(limit)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOver
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(percent * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOver
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.responsiveHeight(0.02)),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 10 * context.responsiveFontSize,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.3,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOver
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.015)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOver
                      ? 'Exceeded by ${currencyFormat.format(spent - limit)}'
                      : 'Remaining: ${currencyFormat.format(limit - spent)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOver
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18 * context.responsiveFontSize,
                      ),
                      onPressed: onEdit,
                    ),
                    SizedBox(width: context.responsiveWidth(0.02)),
                    IconButton.filledTonal(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18 * context.responsiveFontSize,
                      ),
                      onPressed: onDelete,
                      style: IconButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
