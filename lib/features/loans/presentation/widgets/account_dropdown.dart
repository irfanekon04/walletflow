import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../../core/utils/responsive.dart';

class AccountDropdown extends StatelessWidget {
  final String? selectedAccountId;
  final ValueChanged<String?> onChanged;
  final String? labelText;
  final bool isRequired;

  const AccountDropdown({
    super.key,
    this.selectedAccountId,
    required this.onChanged,
    this.labelText,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountController = Get.find<AccountController>();

    return Obx(() {
      final accounts = accountController.accounts;

      if (accounts.isEmpty) {
        return Container(
          padding: EdgeInsets.all(context.responsivePadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              SizedBox(width: context.responsivePadding),
              Expanded(
                child: Text(
                  'No accounts available. Please create an account first.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: selectedAccountId,
        decoration: InputDecoration(
          labelText: labelText ?? (isRequired ? 'Account *' : 'Account'),
          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.responsivePadding,
            vertical: context.responsivePadding * 0.75,
          ),
        ),
        items: accounts.map((account) {
          return DropdownMenuItem<String>(
            value: account.id,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container(
                //   padding: const EdgeInsets.all(6),
                //   decoration: BoxDecoration(
                //     color: _parseColor(account.color).withValues(alpha: 0.2),
                //     borderRadius: BorderRadius.circular(8),
                //   ),
                //   child: Icon(
                //     _getAccountIcon(account.type),
                //     size: 18,
                //     color: _parseColor(account.color),
                //   ),
                // ),
                // SizedBox(width: context.responsivePadding * 0.5),
                Flexible(
                  child: Text(
                    account.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: context.responsivePadding * 0.5),
                Text(
                  _formatBalance(account.balance),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an account';
                }
                return null;
              }
            : null,
      );
    });
  }

  String _formatBalance(double balance) {
    final isNegative = balance < 0;
    final formatted = balance.abs().toStringAsFixed(2);
    return isNegative ? '-\$$formatted' : '\$$formatted';
  }

  // Color _parseColor(String? colorString) {
  //   if (colorString == null || colorString.isEmpty) {
  //     return Colors.blue;
  //   }
  //   try {
  //     return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
  //   } catch (e) {
  //     return Colors.blue;
  //   }
  // }

  // IconData _getAccountIcon(AccountType type) {
  //   switch (type) {
  //     case AccountType.cash:
  //       return Icons.money;
  //     case AccountType.bank:
  //       return Icons.account_balance;
  //     case AccountType.mfs:
  //       return Icons.phone_android;
  //     case AccountType.creditCard:
  //       return Icons.credit_card;
  //   }
  // }
}
