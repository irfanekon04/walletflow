import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:walletflow/core/constants/app_constants.dart';
import 'package:walletflow/core/utils/responsive.dart';
import 'package:walletflow/features/accounts/presentation/controllers/account_controller.dart';
import 'package:walletflow/features/accounts/presentation/pages/account_list_page.dart';

class AccountsSection extends StatelessWidget {
  const AccountsSection({
    super.key,
    required this.controller,
    required this.format,
  });

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
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.accounts,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => const AccountListPage()),
                child: Text(
                  'Manage',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
        12.h.verticalSpacer,
        Obx(() {
          if (controller.accounts.isEmpty) {
            return Card(
              child: Padding(
                padding: EdgeInsets.all(24.r),
                child: Center(
                  child: Text(
                    AppStrings.noAccounts,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: controller.accounts.length,
              itemBuilder: (context, index) {
                final account = controller.accounts[index];
                return Card(
                  margin: EdgeInsets.only(right: 12.w),
                  color: theme.colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                  child: Container(
                    width: 160.w,
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              getAccountIcon(account.type.name),
                              size: 20.sp,
                              color: theme.colorScheme.primary,
                            ),
                            8.w.horizontalSpacer,
                            Expanded(
                              child: Text(
                                account.name,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          format.format(account.balance),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
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
