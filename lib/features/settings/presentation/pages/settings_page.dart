import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/services/data_clear_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final theme = Theme.of(context);
    final RxBool isDarkMode = Get.isDarkMode.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings, style: theme.textTheme.titleLarge),
      ),
      body: ListView(
        padding: EdgeInsets.all(context.responsivePadding),
        children: [
          _buildSectionTitle(context, AppStrings.accounts),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Manage Accounts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      _showAccountsManagement(context, accountController),
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.03)),
          _buildSectionTitle(context, 'Appearance'),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Obx(
              () => SwitchListTile(
                secondary: Icon(
                  isDarkMode.value
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: const Text('Dark Mode'),
                value: isDarkMode.value,
                onChanged: (value) {
                  isDarkMode.value = value;
                  Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.03)),
          _buildSectionTitle(context, 'Data'),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download as CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final exportService = ExportService();
                    exportService.exportAndShare();
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Clear All Data',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.03)),
          _buildSectionTitle(context, 'About'),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Licenses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.04)),
          Center(
            child: Text(
              'Made with ❤️ by irfanekon',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          SizedBox(height: context.responsiveHeight(0.04)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsivePadding,
        0,
        context.responsivePadding,
        8 * context.responsiveFontSize,
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showAccountsManagement(
    BuildContext context,
    AccountController controller,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.accounts,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        _showAddAccountBottomSheet(context, controller),
                  ),
                ],
              ),
              SizedBox(height: context.responsiveHeight(0.02)),
              Expanded(
                child: Obx(() {
                  if (controller.accounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 48,
                            color: theme.colorScheme.outlineVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noAccounts,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.accounts.length,
                    itemBuilder: (context, index) {
                      final account = controller.accounts[index];
                      return Card(
                        margin: EdgeInsets.only(
                          bottom: context.responsiveHeight(0.01),
                        ),
                        color: theme.colorScheme.surfaceContainer,
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(
                              context.responsivePadding * 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getAccountIcon(account.type),
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(
                            account.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            account.type.name.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _showEditAccountBottomSheet(
                                  context,
                                  controller,
                                  account,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: theme.colorScheme.error,
                                ),
                                onPressed: () => _confirmDeleteAccount(
                                  context,
                                  controller,
                                  account,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccountBottomSheet(
    BuildContext context,
    AccountController controller,
  ) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    final creditLimitController = TextEditingController();
    final Rx<AccountType> selectedType = AccountType.cash.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addAccount,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => SegmentedButton<AccountType>(
                  segments: AccountType.values
                      .map(
                        (type) => ButtonSegment(
                          value: type,
                          label: Text(
                            type.name.toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      )
                      .toList(),
                  selected: {selectedType.value},
                  onSelectionChanged: (val) => selectedType.value = val.first,
                ),
              ),
              SizedBox(height: context.responsiveHeight(0.03)),
              AppTextField(controller: nameController, label: 'Account Name'),
              const SizedBox(height: 16),
              AppAmountField(
                controller: balanceController,
                label: 'Initial Balance',
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (selectedType.value == AccountType.creditCard) {
                  return AppAmountField(
                    controller: creditLimitController,
                    label: 'Credit Limit',
                  );
                }
                return const SizedBox.shrink();
              }),
              SizedBox(height: context.responsiveHeight(0.04)),
              AppButton(
                label: AppStrings.save,
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final balance =
                        double.tryParse(balanceController.text) ?? 0;
                    final creditLimit = double.tryParse(
                      creditLimitController.text,
                    );
                    await controller.addAccount(
                      name: nameController.text,
                      type: selectedType.value,
                      balance: balance,
                      creditLimit: creditLimit,
                    );
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAccountBottomSheet(
    BuildContext context,
    AccountController controller,
    AccountModel account,
  ) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: account.name);
    final creditLimitController = TextEditingController(
      text: account.creditLimit?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(controller: nameController, label: 'Account Name'),
              const SizedBox(height: 16),
              if (account.type == AccountType.creditCard)
                AppAmountField(
                  controller: creditLimitController,
                  label: 'Credit Limit',
                ),
              SizedBox(height: context.responsiveHeight(0.04)),
              AppButton(
                label: AppStrings.save,
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final updated = account.copyWith(
                      name: nameController.text,
                      creditLimit: double.tryParse(creditLimitController.text),
                    );
                    await controller.updateAccount(updated);
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AccountController controller,
    AccountModel account,
  ) async {
    final confirmed = await ConfirmDialog.show(
      title: 'Delete Account',
      message: 'Are you sure you want to delete "${account.name}"?',
      confirmText: AppStrings.delete,
      isDestructive: true,
    );

    if (confirmed == true) {
      controller.deleteAccount(account.id);
    }
  }

  void _showClearDataDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            const Text('Clear All Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently delete all your data including:'),
            SizedBox(height: 12),
            Text('• Accounts'),
            Text('• Transactions'),
            Text('• Budgets'),
            Text('• Loans'),
            SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearLocalData();
            },
            child: const Text('Clear Local Data'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearLocalData() async {
    Get.dialog(const LoadingIndicator(), barrierDismissible: false);

    final dataClearService = DataClearService();
    await dataClearService.clearAllLocalData();

    Get.back(); // Close loading dialog

    // Refresh controllers
    Get.find<AccountController>().loadAccounts();

    SnackbarHelper.success('All local data has been cleared', title: 'Success');
  }

  Future<void> _clearAllData() async {
    Get.dialog(const LoadingIndicator(), barrierDismissible: false);

    final dataClearService = DataClearService();
    await dataClearService.clearAllDataIncludingCloud();

    Get.back(); // Close loading dialog

    // Navigate to login
    Get.offAllNamed('/login');
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return Icons.account_balance_wallet_outlined;
      case AccountType.bank:
        return Icons.account_balance_outlined;
      case AccountType.mfs:
        return Icons.phone_android_outlined;
      case AccountType.creditCard:
        return Icons.credit_card_outlined;
    }
  }
}
