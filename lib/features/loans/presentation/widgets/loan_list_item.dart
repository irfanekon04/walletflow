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
      margin: EdgeInsets.only(bottom: context.responsiveHeight(0.015)),
      color: theme.colorScheme.surfaceContainerLow,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.responsivePadding,
          vertical: context.responsivePadding * 0.5,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isLent 
                ? theme.colorScheme.primary 
                : theme.colorScheme.error).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            isLent ? Icons.arrow_outward : Icons.arrow_downward,
            color: isLent ? theme.colorScheme.primary : theme.colorScheme.error,
            size: 20 * context.responsiveFontSize,
          ),
        ),
        title: Text(
          loan.personName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaining: ${currencyFormat.format(remaining)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              controller.getAccountById(loan.accountId)?.name ?? 'Unknown Account',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 10,
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
                  ),
                ),
                Text(
                  isLent ? AppStrings.lent : AppStrings.owed,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 20,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                onPressed: onAddMore,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
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
