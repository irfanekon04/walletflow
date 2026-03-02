import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/transaction_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../dialogs.dart/transaction_dialogs.dart';
import '../controllers/transaction_controller.dart';

class TransferListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransferListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    final accountController = Get.find<AccountController>();
    final fromAccount = accountController.accounts.firstWhereOrNull(
      (a) => a.id == transaction.accountId,
    );
    final toAccount = accountController.accounts.firstWhereOrNull(
      (a) => a.id == transaction.toAccountId,
    );

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
            color: theme.colorScheme.tertiary.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.swap_horiz,
            color: theme.colorScheme.tertiary,
            size: 20 * context.responsiveFontSize,
          ),
        ),
        title: Text(
          'Transfer',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'From ${fromAccount?.name ?? 'Unknown'} → To ${toAccount?.name ?? 'Unknown'}${transaction.note != null ? '\n${transaction.note}' : ''}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        onTap: () {
          final controller = Get.find<TransactionController>();
          TransactionDialogs.showEditTransactionBottomSheet(
            context,
            controller,
            accountController,
            transaction,
          );
        },
        onLongPress: () {
          TransactionDialogs.showDeleteConfirmation(
            context,
            transaction,
          );
        },
      ),
    );
  }
}
