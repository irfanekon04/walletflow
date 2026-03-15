import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/services/data_clear_service.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../accounts/presentation/pages/account_list_page.dart';
import '../../../transactions/presentation/pages/category_list_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late RxBool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = Get.isDarkMode.obs;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings, style: theme.textTheme.titleLarge),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          _buildSectionTitle(context, AppStrings.accounts),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: Text(
                    'Manage Accounts',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.to(() => const AccountListPage()),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(
                    'Manage Categories',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.to(() => const CategoryListPage()),
                ),
              ],
            ),
          ),
          24.h.verticalSpacer,
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
                title: Text(
                  'Dark Mode',
                  style: TextStyle(fontSize: 14.sp),
                ),
                value: isDarkMode.value,
                onChanged: (value) {
                  isDarkMode.value = value;
                  Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
          ),
          24.h.verticalSpacer,
          _buildSectionTitle(context, 'Data'),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: Text(
                    'Export Data',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  subtitle: Text(
                    'Download as CSV',
                    style: TextStyle(fontSize: 12.sp),
                  ),
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
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 14.sp,
                    ),
                  ),
                  onTap: () => _showClearDataDialog(context),
                ),
              ],
            ),
          ),
          24.h.verticalSpacer,
          _buildSectionTitle(context, 'About'),
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(
                    'App Version',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  subtitle: Text(
                    '1.0.0',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    'Licenses',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
          32.h.verticalSpacer,
          Center(
            child: Text(
              'Made with ❤️ by irfanekon',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
                fontSize: 11.sp,
              ),
            ),
          ),
          32.h.verticalSpacer,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.r,
        0,
        16.r,
        8.h,
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
}
