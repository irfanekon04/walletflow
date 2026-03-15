import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../controllers/account_controller.dart';
import '../widgets/account_dialogs.dart';

class AccountListPage extends StatelessWidget {
  const AccountListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AccountController>();
    final theme = Theme.of(context);
    final format = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Accounts')),
      body: Obx(() {
        if (controller.accounts.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.account_balance_wallet_outlined,
            title: AppStrings.noAccounts,
            subtitle:
                'Add bank accounts, cash, or credit cards to track your net worth.',
            actionLabel: 'Add Account',
            onAction: () =>
                AccountDialogs.showAddAccountBottomSheet(context, controller),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16.r,
            16.r,
            16.r,
            100.h,
          ),
          itemCount: controller.accounts.length,
          itemBuilder: (context, index) {
            final account = controller.accounts[index];
            final icon = AccountDialogs.getAccountIcon(account.type);

            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              color: theme.colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.r,
                  vertical: 8.h,
                ),
                leading: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24.sp,
                  ),
                ),
                title: Text(
                  account.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.type.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    if (account.creditLimit != null)
                      Text(
                        'Limit: ${format.format(account.creditLimit)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      format.format(account.balance),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: account.balance < 0
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        fontSize: 16.sp,
                      ),
                    ),
                    8.w.horizontalSpacer,
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 20.sp),
                              8.w.horizontalSpacer,
                              Text('Edit', style: TextStyle(fontSize: 14.sp)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20.sp,
                                color: Colors.red,
                              ),
                              8.w.horizontalSpacer,
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          AccountDialogs.showEditAccountBottomSheet(
                            context,
                            controller,
                            account,
                          );
                        } else if (value == 'delete') {
                          AccountDialogs.confirmDeleteAccount(
                            context,
                            controller,
                            account,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            AccountDialogs.showAddAccountBottomSheet(context, controller),
        icon: const Icon(Icons.add),
        label: const Text('New Account'),
      ),
    );
  }
}
