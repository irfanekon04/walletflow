import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/category_model.dart';
import '../controllers/transaction_controller.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TransactionController>();
    final accountController = Get.find<AccountController>();
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.transactions, style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () =>
                _showFilterBottomSheet(context, controller, accountController),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(context, controller),
          Expanded(
            child: Obx(() {
              if (controller.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64 * context.responsiveFontSize,
                        color: theme.colorScheme.outlineVariant,
                      ),
                      SizedBox(height: context.responsiveHeight(0.02)),
                      Text(
                        AppStrings.noTransactions,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(context.responsivePadding),
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  final category = controller.getCategoryById(
                    transaction.categoryId ?? '',
                  );
                  final color = category != null
                      ? Color(
                          int.parse(
                            category.color.replaceFirst('#', 'FF'),
                            radix: 16,
                          ),
                        )
                      : theme.colorScheme.secondary;

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
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getCategoryIcon(category?.icon ?? 'category'),
                          color: color,
                          size: 20 * context.responsiveFontSize,
                        ),
                      ),
                      title: Text(
                        category?.name ?? 'Uncategorized',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${DateFormat('MMM dd, yyyy').format(transaction.date)}${transaction.note != null ? ' - ${transaction.note}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Text(
                        '${transaction.type == TransactionType.expense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: transaction.type == TransactionType.expense
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      onTap: () => _showTransactionDetails(
                        context,
                        transaction,
                        category,
                        currencyFormat,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        heroTag: 'transactions_fab',
        onPressed: () => _showAddTransactionBottomSheet(
          context,
          controller,
          accountController,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    TransactionController controller,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(
        () => Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: controller.filterType.value == null,
              onSelected: (_) => controller.filterType.value = null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.income),
              selected: controller.filterType.value == TransactionType.income,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.income,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.expense),
              selected: controller.filterType.value == TransactionType.expense,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.expense,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: context.responsiveWidth(0.02)),
            FilterChip(
              label: const Text(AppStrings.transfer),
              selected: controller.filterType.value == TransactionType.transfer,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.transfer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    TransactionController controller,
    AccountController accountController,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Account', style: theme.textTheme.titleLarge),
            SizedBox(height: context.responsiveHeight(0.02)),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: controller.filterAccountId.value.isEmpty,
                    onSelected: (_) => controller.filterAccountId.value = '',
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  ...accountController.accounts.map(
                    (acc) => ChoiceChip(
                      label: Text(acc.name),
                      selected: controller.filterAccountId.value == acc.id,
                      onSelected: (_) =>
                          controller.filterAccountId.value = acc.id,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.04)),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                      Get.back();
                    },
                    child: const Text('Clear'),
                  ),
                ),
                SizedBox(width: context.responsiveWidth(0.03)),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Get.back(),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionBottomSheet(
    BuildContext context,
    TransactionController controller,
    AccountController accountController,
  ) {
    final theme = Theme.of(context);
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final Rx<TransactionType> selectedType = TransactionType.expense.obs;
    final RxString selectedAccountId = ''.obs;
    final RxString selectedCategoryId = ''.obs;
    final Rx<DateTime> selectedDate = DateTime.now().obs;

    if (accountController.accounts.isNotEmpty) {
      selectedAccountId.value = accountController.accounts.first.id;
    }

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
                AppStrings.addTransaction,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.responsiveHeight(0.025)),
              Obx(
                () => SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(AppStrings.expense),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text(AppStrings.income),
                    ),
                    ButtonSegment(
                      value: TransactionType.transfer,
                      label: Text(AppStrings.transfer),
                    ),
                  ],
                  selected: {selectedType.value},
                  onSelectionChanged: (val) => selectedType.value = val.first,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: selectedAccountId.value.isEmpty
                      ? null
                      : selectedAccountId.value,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: accountController.accounts
                      .map(
                        (acc) => DropdownMenuItem(
                          value: acc.id,
                          child: Text(acc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedAccountId.value = value ?? '',
                ),
              ),
              SizedBox(height: context.responsiveHeight(0.015)),
              Obx(() {
                final categories = selectedType.value == TransactionType.expense
                    ? controller.expenseCategories
                    : controller.incomeCategories;
                return DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId.value.isEmpty
                      ? null
                      : selectedCategoryId.value,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedCategoryId.value = value ?? '',
                );
              }),
              SizedBox(height: context.responsiveHeight(0.015)),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              SizedBox(height: context.responsiveHeight(0.03)),
              SizedBox(
                width: double.infinity,
                height: 56 * context.responsiveFontSize,
                child: FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null &&
                        amount > 0 &&
                        selectedAccountId.value.isNotEmpty) {
                      await controller.addTransaction(
                        accountId: selectedAccountId.value,
                        type: selectedType.value,
                        amount: amount,
                        categoryId: selectedCategoryId.value.isEmpty
                            ? null
                            : selectedCategoryId.value,
                        note: noteController.text.isEmpty
                            ? null
                            : noteController.text,
                        date: selectedDate.value,
                      );
                      accountController.loadAccounts();
                      if (context.mounted) Get.back();
                    }
                  },
                  child: const Text(AppStrings.save),
                ),
              ),
              SizedBox(height: context.responsiveHeight(0.015)),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    CategoryModel? category,
    NumberFormat format,
  ) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category?.name ?? 'Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ${transaction.type == TransactionType.expense ? '-' : '+'}${format.format(transaction.amount)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: transaction.type == TransactionType.expense
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.01)),
            Text(
              'Date: ${DateFormat('MMMM dd, yyyy').format(transaction.date)}',
            ),
            if (transaction.note != null) ...[
              SizedBox(height: context.responsiveHeight(0.01)),
              Text('Note: ${transaction.note}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _showDeleteConfirmation(context, transaction);
            },
            child: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _showEditTransactionBottomSheet(
                context,
                Get.find<TransactionController>(),
                Get.find<AccountController>(),
                transaction,
              );
            },
            child: const Text('Edit'),
          ),
          FilledButton.tonal(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final theme = Theme.of(context);
    final controller = Get.find<TransactionController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await controller.deleteTransaction(transaction.id);

              final accountController = Get.find<AccountController>();
              if (transaction.type == TransactionType.expense) {
                await accountController.updateBalance(
                  transaction.accountId,
                  transaction.amount,
                  isAdd: true,
                );
              } else if (transaction.type == TransactionType.income) {
                await accountController.updateBalance(
                  transaction.accountId,
                  transaction.amount,
                  isAdd: false,
                );
              } else if (transaction.type == TransactionType.transfer &&
                  transaction.toAccountId != null) {
                await accountController.updateBalance(
                  transaction.accountId,
                  transaction.amount,
                  isAdd: true,
                );
                await accountController.updateBalance(
                  transaction.toAccountId!,
                  transaction.amount,
                  isAdd: false,
                );
              }
              accountController.loadAccounts();
              if (context.mounted) Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditTransactionBottomSheet(
    BuildContext context,
    TransactionController controller,
    AccountController accountController,
    TransactionModel transaction,
  ) {
    final theme = Theme.of(context);
    final amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final noteController = TextEditingController(text: transaction.note ?? '');
    final Rx<TransactionType> selectedType = transaction.type.obs;
    final RxString selectedAccountId = transaction.accountId.obs;
    final RxString selectedCategoryId = (transaction.categoryId ?? '').obs;
    final Rx<DateTime> selectedDate = transaction.date.obs;

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
                'Edit Transaction',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: context.responsiveHeight(0.025)),
              Obx(
                () => SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(AppStrings.expense),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text(AppStrings.income),
                    ),
                    ButtonSegment(
                      value: TransactionType.transfer,
                      label: Text(AppStrings.transfer),
                    ),
                  ],
                  selected: {selectedType.value},
                  onSelectionChanged: (val) => selectedType.value = val.first,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => DropdownButtonFormField<String>(
                  initialValue: selectedAccountId.value.isEmpty
                      ? null
                      : selectedAccountId.value,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: accountController.accounts
                      .map(
                        (acc) => DropdownMenuItem(
                          value: acc.id,
                          child: Text(acc.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedAccountId.value = value ?? '',
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final categories = selectedType.value == TransactionType.expense
                    ? controller.expenseCategories
                    : controller.incomeCategories;
                return DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId.value.isEmpty
                      ? null
                      : selectedCategoryId.value,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => selectedCategoryId.value = value ?? '',
                );
              }),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null &&
                        amount > 0 &&
                        selectedAccountId.value.isNotEmpty) {
                      final oldType = transaction.type;
                      final oldAccountId = transaction.accountId;
                      final oldAmount = transaction.amount;

                      transaction.accountId = selectedAccountId.value;
                      transaction.type = selectedType.value;
                      transaction.amount = amount;
                      transaction.categoryId = selectedCategoryId.value.isEmpty
                          ? null
                          : selectedCategoryId.value;
                      transaction.note = noteController.text.isEmpty
                          ? null
                          : noteController.text;
                      transaction.date = selectedDate.value;

                      await controller.updateTransaction(transaction);

                      if (oldType == TransactionType.expense) {
                        await accountController.updateBalance(
                          oldAccountId,
                          oldAmount,
                          isAdd: true,
                        );
                      } else if (oldType == TransactionType.income) {
                        await accountController.updateBalance(
                          oldAccountId,
                          oldAmount,
                          isAdd: false,
                        );
                      }

                      if (selectedType.value == TransactionType.expense) {
                        await accountController.updateBalance(
                          selectedAccountId.value,
                          amount,
                          isAdd: false,
                        );
                      } else if (selectedType.value == TransactionType.income) {
                        await accountController.updateBalance(
                          selectedAccountId.value,
                          amount,
                          isAdd: true,
                        );
                      }

                      accountController.loadAccounts();
                      if (context.mounted) Get.back();
                    }
                  },
                  child: const Text(AppStrings.save),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'directions_car':
        return Icons.directions_car_outlined;
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'movie':
        return Icons.movie_outlined;
      case 'medical_services':
        return Icons.medical_services_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.category_outlined;
    }
  }
}
