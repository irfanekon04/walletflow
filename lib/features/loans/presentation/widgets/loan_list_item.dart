import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import '../../data/models/loan_model.dart';
import '../controllers/loan_controller.dart';

class LoanListItem extends StatelessWidget {
  final LoanModel loan;
  final LoanController controller;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;
  final VoidCallback onAddMore;

  const LoanListItem({
    super.key,
    required this.loan,
    required this.controller,
    required this.currencyFormat,
    required this.onTap,
    required this.onAddMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = loan.amount - loan.paidAmount;
    final isLent = loan.type == LoanType.lent;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.r,
          vertical: 8.h,
        ),
        leading: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: (isLent 
                ? theme.colorScheme.primary 
                : theme.colorScheme.error).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Icon(
            isLent ? Icons.arrow_outward : Icons.arrow_downward,
            color: isLent ? theme.colorScheme.primary : theme.colorScheme.error,
            size: 20.sp,
          ),
        ),
        title: Text(
          loan.personName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaining: ${currencyFormat.format(remaining)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
            Text(
              controller.getAccountById(loan.accountId)?.name ?? 'Unknown Account',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(loan.amount),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLent ? theme.colorScheme.primary : theme.colorScheme.error,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  isLent ? AppStrings.lent : AppStrings.owed,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
            8.w.horizontalSpacer,
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 20.sp,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                onPressed: onAddMore,
                constraints: BoxConstraints(
                  minWidth: 36.r,
                  minHeight: 36.r,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
