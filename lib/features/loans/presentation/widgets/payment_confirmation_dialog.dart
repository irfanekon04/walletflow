import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';

class PaymentConfirmationDialog extends StatelessWidget {
  final double amount;
  final String accountName;
  final bool isLent;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;

  const PaymentConfirmationDialog({
    super.key,
    required this.amount,
    required this.accountName,
    required this.isLent,
    required this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required double amount,
    required String accountName,
    required bool isLent,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => PaymentConfirmationDialog(
        amount: amount,
        accountName: accountName,
        isLent: isLent,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = isLent;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isIncome ? Icons.call_received : Icons.call_made,
            color: isIncome ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          SizedBox(width: context.responsivePadding * 0.5),
          Text('Confirm Payment'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            Icons.attach_money,
            'Amount',
            '\$${amount.toStringAsFixed(2)}',
            theme.colorScheme.primary,
          ),
          SizedBox(height: context.responsivePadding * 0.5),
          _buildInfoRow(
            context,
            Icons.account_balance_wallet,
            'Account',
            accountName,
            theme.colorScheme.secondary,
          ),
          SizedBox(height: context.responsivePadding),
          Container(
            padding: EdgeInsets.all(context.responsivePadding * 0.75),
            decoration: BoxDecoration(
              color: (isIncome
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: (isIncome
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isIncome ? Icons.add_circle : Icons.remove_circle,
                  color: isIncome
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  size: 20,
                ),
                SizedBox(width: context.responsivePadding * 0.5),
                Expanded(
                  child: Text(
                    isIncome
                        ? 'This will add \$${amount.toStringAsFixed(2)} to $accountName as income'
                        : 'This will deduct \$${amount.toStringAsFixed(2)} from $accountName as expense',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isIncome
                          ? theme.colorScheme.primary
                          : theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsivePadding * 0.5),
          Text(
            'Loan balance will be updated accordingly.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor:
                isIncome ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: context.responsivePadding * 0.5),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
