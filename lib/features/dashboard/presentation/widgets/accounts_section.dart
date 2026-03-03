import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/features/accounts/presentation/controllers/account_controller.dart';

class AccountsSection extends StatelessWidget {
  const AccountsSection({
    super.key,
    required this.context,
    required this.controller,
    required this.format,
  });

  final BuildContext context;
  final AccountController controller;
  final NumberFormat format;
  
  
  IconData getAccountIcon(String type) {
      switch (type) {
        case 'cash':
          return Icons.account_balance_wallet_outlined;
        case 'bank':
          return Icons.account_balance_outlined;
        case 'mfs':
          return Icons.phone_android_outlined;
        case 'creditCard':
          return Icons.credit_card_outlined;
        default:
          return Icons.account_balance_wallet_outlined;
      }
    }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppStrings.accounts,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.accounts.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    AppStrings.noAccounts,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            height: context.responsiveHeight(0.14),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: controller.accounts.length,
              itemBuilder: (context, index) {
                final account = controller.accounts[index];
                return Card(
                  margin: EdgeInsets.only(right: context.responsiveWidth(0.03)),
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Container(
                    width: context.isTabletWidth ? 200 : 160,
                    padding: EdgeInsets.all(context.responsivePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              getAccountIcon(account.type.name),
                              size: 20 * context.responsiveFontSize,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: context.responsiveWidth(0.02)),
                            Expanded(
                              child: Text(
                                account.name,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          format.format(account.balance),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20 * context.responsiveFontSize,
                            color: account.balance < 0
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
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
