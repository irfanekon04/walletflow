import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/transaction_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = context.screenWidth;
    final isCompact = screenWidth < 360;
    
    final numberFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd');
    
    final accountController = Get.find<AccountController>();
    final fromAccount = accountController.accounts
        .firstWhereOrNull((a) => a.id == transaction.accountId);
    final toAccount = accountController.accounts
        .firstWhereOrNull((a) => a.id == transaction.toAccountId);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsivePadding,
        vertical: AppDimensions.paddingXS,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 10 : 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: isCompact ? 18 : 22,
                backgroundColor: colorScheme.tertiary.withOpacity(0.15),
                child: Icon(
                  Icons.swap_horiz,
                  size: isCompact ? 18 : 22,
                  color: colorScheme.tertiary,
                ),
              ),
              SizedBox(width: isCompact ? 10 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transfer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isCompact ? 13 : 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'From ${fromAccount?.name ?? 'Unknown'} → To ${toAccount?.name ?? 'Unknown'}',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isCompact ? 11 : 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        transaction.note!,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontSize: isCompact ? 10 : 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    numberFormat.format(transaction.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 14 : 16,
                      color: colorScheme.tertiary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    dateFormat.format(transaction.date),
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: isCompact ? 10 : 12,
                    ),
                  ),
                ],
              ),
              if (onDelete != null) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: isCompact ? 18 : 20,
                    color: Colors.red[400],
                  ),
                  onPressed: onDelete,
                  constraints: BoxConstraints(
                    minWidth: isCompact ? 32 : 40,
                    minHeight: isCompact ? 32 : 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
