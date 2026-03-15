import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_dropdown.dart';

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

      return AppDropdown<String>(
        value: selectedAccountId,
        label: labelText ?? (isRequired ? 'Account *' : 'Account'),
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
        items: accounts.map((account) {
          return DropdownMenuItem<String>(
            value: account.id,
            child: Row(
              children: [
                Icon(
                  accountController.getAccountIcon(account.type.name),
                  size: 18 * context.responsiveFontSize,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: context.responsivePadding * 0.5),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.name,
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        _formatBalance(account.balance),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
}
