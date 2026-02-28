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
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
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
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        AppStrings.noTransactions,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: AppDimensions.paddingS,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.fromHex(
                          category?.color ?? '#607D8B',
                        ),
                        child: Icon(
                          _getCategoryIcon(category?.icon ?? 'category'),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(category?.name ?? 'Uncategorized'),
                      subtitle: Text(
                        '${DateFormat('MMM dd, yyyy').format(transaction.date)}${transaction.note != null ? ' - ${transaction.note}' : ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: Text(
                        '${transaction.type == TransactionType.expense ? '-' : '+'}${currencyFormat.format(transaction.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction.type == TransactionType.expense
                              ? AppColors.expenseRed
                              : AppColors.incomeGreen,
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
      floatingActionButton: FloatingActionButton(
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
      padding: EdgeInsets.all(AppDimensions.paddingS),
      child: Obx(
        () => Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: controller.filterType.value == null,
              onSelected: (_) => controller.filterType.value = null,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text(AppStrings.income),
              selected: controller.filterType.value == TransactionType.income,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.income,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text(AppStrings.expense),
              selected: controller.filterType.value == TransactionType.expense,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.expense,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text(AppStrings.transfer),
              selected: controller.filterType.value == TransactionType.transfer,
              onSelected: (_) =>
                  controller.filterType.value = TransactionType.transfer,
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
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: controller.filterAccountId.value.isEmpty,
                    onSelected: (_) => controller.filterAccountId.value = '',
                  ),
                  ...accountController.accounts.map(
                    (acc) => ChoiceChip(
                      label: Text(acc.name),
                      selected: controller.filterAccountId.value == acc.id,
                      onSelected: (_) =>
                          controller.filterAccountId.value = acc.id,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
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
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingM,
          right: AppDimensions.paddingM,
          top: AppDimensions.paddingM,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingM,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addTransaction,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text(AppStrings.expense),
                        selected: selectedType.value == TransactionType.expense,
                        onSelected: (_) =>
                            selectedType.value = TransactionType.expense,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text(AppStrings.income),
                        selected: selectedType.value == TransactionType.income,
                        onSelected: (_) =>
                            selectedType.value = TransactionType.income,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text(AppStrings.transfer),
                        selected:
                            selectedType.value == TransactionType.transfer,
                        onSelected: (_) =>
                            selectedType.value = TransactionType.transfer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
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
              const SizedBox(height: AppDimensions.paddingM),
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
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
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

  void _showTransactionDetails(
    BuildContext context,
    TransactionModel transaction,
    CategoryModel? category,
    NumberFormat format,
  ) {
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
            ),
            Text(
              'Date: ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
            ),
            if (transaction.note != null) Text('Note: ${transaction.note}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, transaction);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red[700])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditTransactionBottomSheet(
                context,
                Get.find<TransactionController>(),
                Get.find<AccountController>(),
                transaction,
              );
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    final controller = Get.find<TransactionController>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
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
              if (context.mounted) Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red[700])),
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
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: AppDimensions.paddingM,
          right: AppDimensions.paddingM,
          top: AppDimensions.paddingM,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingM,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text(AppStrings.expense),
                        selected: selectedType.value == TransactionType.expense,
                        onSelected: (_) =>
                            selectedType.value = TransactionType.expense,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text(AppStrings.income),
                        selected: selectedType.value == TransactionType.income,
                        onSelected: (_) =>
                            selectedType.value = TransactionType.income,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text(AppStrings.transfer),
                        selected:
                            selectedType.value == TransactionType.transfer,
                        onSelected: (_) =>
                            selectedType.value = TransactionType.transfer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
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
              const SizedBox(height: AppDimensions.paddingM),
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
              const SizedBox(height: AppDimensions.paddingM),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              SizedBox(
                width: double.infinity,
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

  IconData _getCategoryIcon(String icon) {
    switch (icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'movie':
        return Icons.movie;
      case 'medical_services':
        return Icons.medical_services;
      case 'school':
        return Icons.school;
      case 'work':
        return Icons.work;
      default:
        return Icons.category;
    }
  }
}
