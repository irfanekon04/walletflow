import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/core/constants/app_constants.dart';

class LoanSummaryCard extends StatelessWidget {
  final double totalLent;
  final double totalOwed;
  final double netPosition;
  final NumberFormat currencyFormat;

  const LoanSummaryCard({
    super.key,
    required this.totalLent,
    required this.totalOwed,
    required this.netPosition,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            context,
            AppStrings.lent,
            totalLent,
            currencyFormat,
            theme.colorScheme.primary,
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: theme.colorScheme.outlineVariant,
          ),
          _buildSummaryItem(
            context,
            AppStrings.owed,
            totalOwed,
            currencyFormat,
            theme.colorScheme.error,
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: theme.colorScheme.outlineVariant,
          ),
          _buildSummaryItem(
            context,
            'Net',
            netPosition,
            currencyFormat,
            netPosition >= 0
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    NumberFormat format,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
        4.h.verticalSpacer,
        Text(
          format.format(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16.sp,
          ),
        ),

      ],
    );
  }
}
