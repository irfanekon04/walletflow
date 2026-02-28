import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<AccountController>();
    final RxBool isDarkMode = false.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        padding: EdgeInsets.all(context.responsivePadding),
        children: [
          _buildSectionTitle(context, AppStrings.accounts),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Manage Accounts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAccountsManagement(context, accountController),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildSectionTitle(context, 'Appearance'),
          Card(
            child: Obx(() => SwitchListTile(
              secondary: Icon(isDarkMode.value ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Dark Mode'),
              value: isDarkMode.value,
              onChanged: (value) {
                isDarkMode.value = value;
                Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
            )),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildSectionTitle(context, 'Cloud'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Sync Status'),
                  subtitle: const Text('Last synced: Never'),
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Sync Now'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Sign In'),
                  subtitle: const Text('Enable cloud backup'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildSectionTitle(context, 'Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download as CSV'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.expenseRed),
                  title: const Text('Clear All Data', style: TextStyle(color: AppColors.expenseRed)),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          _buildSectionTitle(context, 'About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Licenses'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14 * context.responsiveFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showAccountsManagement(BuildContext context, AccountController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.accounts,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddAccountBottomSheet(context, controller),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Obx(() {
                  if (controller.accounts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: AppDimensions.paddingM),
                          Text(AppStrings.noAccounts, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.accounts.length,
                    itemBuilder: (context, index) {
                      final account = controller.accounts[index];
                      return ListTile(
                        leading: Icon(_getAccountIcon(account.type)),
                        title: Text(account.name),
                        subtitle: Text(account.type.name.toUpperCase()),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showEditAccountBottomSheet(context, controller, account),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.expenseRed),
                              onPressed: () => _confirmDeleteAccount(context, controller, account),
                            ),
                          ],
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

  void _showAddAccountBottomSheet(BuildContext context, AccountController controller) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');
    final creditLimitController = TextEditingController();
    final Rx<AccountType> selectedType = AccountType.cash.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingM,
          right: AppDimensions.paddingM,
          top: AppDimensions.paddingM,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingM,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.addAccount, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.paddingM),
              Obx(() => Wrap(
                spacing: 8,
                children: AccountType.values.map((type) => ChoiceChip(
                  label: Text(type.name.toUpperCase()),
                  selected: selectedType.value == type,
                  onSelected: (_) => selectedType.value = type,
                )).toList(),
              )),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Initial Balance', prefixText: '\$ '),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Obx(() {
                if (selectedType.value == AccountType.creditCard) {
                  return TextField(
                    controller: creditLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Credit Limit', prefixText: '\$ '),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      final balance = double.tryParse(balanceController.text) ?? 0;
                      final creditLimit = double.tryParse(creditLimitController.text);
                      await controller.addAccount(
                        name: nameController.text,
                        type: selectedType.value,
                        balance: balance,
                        creditLimit: creditLimit,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAccountBottomSheet(BuildContext context, AccountController controller, AccountModel account) {
    final nameController = TextEditingController(text: account.name);
    final creditLimitController = TextEditingController(text: account.creditLimit?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingM,
          right: AppDimensions.paddingM,
          top: AppDimensions.paddingM,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingM,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              if (account.type == AccountType.creditCard)
                TextField(
                  controller: creditLimitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Credit Limit', prefixText: '\$ '),
                ),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      final updated = account.copyWith(
                        name: nameController.text,
                        creditLimit: double.tryParse(creditLimitController.text),
                      );
                      await controller.updateAccount(updated);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AccountController controller, AccountModel account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteAccount(account.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all your data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expenseRed),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.cash: return Icons.wallet;
      case AccountType.bank: return Icons.account_balance;
      case AccountType.mfs: return Icons.phone_android;
      case AccountType.creditCard: return Icons.credit_card;
    }
  }
}
