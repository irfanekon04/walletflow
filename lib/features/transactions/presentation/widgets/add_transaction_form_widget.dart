import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../data/models/transaction_model.dart';
import '../controllers/transaction_controller.dart';

class AddTransactionFormWidget extends StatefulWidget {
  final VoidCallback onSaved;
  final TransactionModel? existingTransaction;

  const AddTransactionFormWidget({
    super.key,
    required this.onSaved,
    this.existingTransaction,
  });

  @override
  State<AddTransactionFormWidget> createState() =>
      _AddTransactionFormWidgetState();
}

class _AddTransactionFormWidgetState extends State<AddTransactionFormWidget> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _selectedType;
  late String _selectedAccountId;
  String _selectedToAccountId = '';
  String _selectedCategoryId = '';
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _selectedType = existing?.type ?? TransactionType.expense;
    _selectedAccountId = existing?.accountId ?? '';
    _selectedToAccountId = existing?.toAccountId ?? '';
    _selectedCategoryId = existing?.categoryId ?? '';
    _selectedDate = existing?.date ?? DateTime.now();

    if (existing != null) {
      _amountController.text = existing.amount.toString();
      _noteController.text = existing.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accountController = Get.find<AccountController>();
    final transactionController = Get.find<TransactionController>();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.existingTransaction != null
                  ? 'Edit Transaction'
                  : AppStrings.addTransaction,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.responsiveHeight(0.025)),

            _buildTypeSelector(),
            SizedBox(height: 20),

            _buildAmountField(theme),
            SizedBox(height: 20),

            _buildFromAccountDropdown(accountController),

            if (_selectedType == TransactionType.transfer) ...[
              SizedBox(height: 16),
              _buildToAccountDropdown(accountController),
            ],

            if (_selectedType != TransactionType.transfer) ...[
              SizedBox(height: 16),
              _buildCategoryDropdown(transactionController),
            ],

            SizedBox(height: 16),
            _buildNoteField(),
            SizedBox(height: 24),

            _buildSaveButton(transactionController, accountController),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final isEditing = widget.existingTransaction != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.amber[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Changing type will update account balances',
                      style: TextStyle(fontSize: 12, color: Colors.amber[800]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        SegmentedButton<TransactionType>(
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
          selected: {_selectedType},
          onSelectionChanged: (val) {
            final newType = val.first;
            final accountController = Get.find<AccountController>();

            if (newType == TransactionType.transfer &&
                accountController.accounts.length < 2) {
              Get.snackbar(
                'Error',
                'Need at least 2 accounts to create a transfer',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red[400],
                colorText: Colors.white,
              );
              return;
            }

            setState(() {
              if (newType == TransactionType.transfer) {
                _selectedCategoryId = '';
                if (accountController.accounts.length > 1) {
                  _selectedToAccountId = accountController.accounts
                      .firstWhere(
                        (a) => a.id != _selectedAccountId,
                        orElse: () => accountController.accounts.first,
                      )
                      .id;
                }
              } else {
                _selectedToAccountId = '';
                if (_selectedType == TransactionType.expense ||
                    _selectedType == TransactionType.income) {
                  _selectedCategoryId = '';
                }
              }
              _selectedType = newType;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: theme.textTheme.headlineMedium,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: '\$ ',
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
      ),
    );
  }

  Widget _buildFromAccountDropdown(AccountController accountController) {
    final theme = Theme.of(context);
    return StatefulBuilder(
      builder: (context, setDropdownState) {
        // Validate current value exists
        String? validValue;
        if (_selectedAccountId.isNotEmpty) {
          final exists = accountController.accounts.any(
            (a) => a.id == _selectedAccountId,
          );
          validValue = exists
              ? _selectedAccountId
              : (accountController.accounts.isNotEmpty
                    ? accountController.accounts.first.id
                    : null);
        }

        return DropdownButtonFormField<String>(
          initialValue: validValue,
          decoration: const InputDecoration(labelText: 'Account'),
          items: accountController.accounts
              .map(
                (acc) => DropdownMenuItem(
                  value: acc.id,
                  child: Text(
                    acc.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccountId = value ?? '';
              // Reset To Account if it becomes invalid
              if (_selectedType == TransactionType.transfer &&
                  _selectedToAccountId.isNotEmpty &&
                  _selectedToAccountId == value) {
                final availableAccounts = accountController.accounts
                    .where((a) => a.id != value)
                    .toList();
                if (availableAccounts.isNotEmpty) {
                  _selectedToAccountId = availableAccounts.first.id;
                }
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Theme.of(context).colorScheme.surfaceDim,
        );
      },
    );
  }

  Widget _buildToAccountDropdown(AccountController accountController) {
    final availableAccounts = accountController.accounts
        .where((a) => a.id != _selectedAccountId)
        .toList();
    final theme = Theme.of(context);
    // Validate current value exists in filtered list
    String? validValue;
    if (_selectedToAccountId.isNotEmpty) {
      final exists = availableAccounts.any((a) => a.id == _selectedToAccountId);
      validValue = exists
          ? _selectedToAccountId
          : (availableAccounts.isNotEmpty ? availableAccounts.first.id : null);
    }

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      decoration: const InputDecoration(
        labelText: 'To Account',
        prefixIcon: Icon(Icons.arrow_downward),
      ),
      items: availableAccounts
          .map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedToAccountId = value ?? '';
        });
      },
    );
  }

  Widget _buildCategoryDropdown(TransactionController transactionController) {
    final categories = _selectedType == TransactionType.expense
        ? transactionController.expenseCategories
        : transactionController.incomeCategories;
    final theme = Theme.of(context);

    if (categories.isEmpty) return const SizedBox.shrink();

    // Validate current value exists in filtered list
    String? validValue;
    if (_selectedCategoryId.isNotEmpty) {
      final exists = categories.any((c) => c.id == _selectedCategoryId);
      validValue = exists ? _selectedCategoryId : null;
    }

    return DropdownButtonFormField<String>(
      initialValue: validValue,
      decoration: const InputDecoration(labelText: 'Category'),
      items: categories
          .map(
            (cat) => DropdownMenuItem(
              value: cat.id,
              child: Text(
                cat.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value ?? '';
        });
      },
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      decoration: const InputDecoration(labelText: 'Note (optional)'),
    );
  }

  Widget _buildSaveButton(
    TransactionController transactionController,
    AccountController accountController,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: () => _handleSave(transactionController, accountController),
        child: const Text(AppStrings.save),
      ),
    );
  }

  Future<void> _handleSave(
    TransactionController transactionController,
    AccountController accountController,
  ) async {
    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0 || _selectedAccountId.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount and select an account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    final isEditing = widget.existingTransaction != null;

    if (isEditing) {
      final originalTransaction = widget.existingTransaction!;
      final originalType = originalTransaction.type;
      final typeChanged = originalType != _selectedType;

      if (typeChanged) {
        await transactionController.updateTransactionWithTypeChange(
          transaction: originalTransaction,
          newType: _selectedType,
          newAccountId: _selectedAccountId,
          newToAccountId: _selectedType == TransactionType.transfer
              ? _selectedToAccountId
              : null,
          newAmount: amount,
          newCategoryId: _selectedType != TransactionType.transfer
              ? (_selectedCategoryId.isEmpty ? null : _selectedCategoryId)
              : null,
          newNote: _noteController.text.isEmpty ? null : _noteController.text,
          newDate: _selectedDate,
        );
      } else {
        if (_selectedType == TransactionType.transfer) {
          await transactionController.updateTransfer(
            transaction: originalTransaction,
            newFromAccountId: _selectedAccountId,
            newToAccountId: _selectedToAccountId,
            newAmount: amount,
            newNote: _noteController.text.isEmpty ? null : _noteController.text,
            newDate: _selectedDate,
          );
        } else {
          originalTransaction.accountId = _selectedAccountId;
          originalTransaction.amount = amount;
          originalTransaction.categoryId = _selectedCategoryId.isEmpty
              ? null
              : _selectedCategoryId;
          originalTransaction.note = _noteController.text.isEmpty
              ? null
              : _noteController.text;
          originalTransaction.date = _selectedDate;
          await transactionController.updateTransaction(originalTransaction);
        }
      }
    } else {
      if (_selectedType == TransactionType.transfer) {
        if (_selectedToAccountId.isEmpty) {
          Get.snackbar(
            'Error',
            'Please select a destination account',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[400],
            colorText: Colors.white,
          );
          return;
        }

        if (_selectedAccountId == _selectedToAccountId) {
          Get.snackbar(
            'Error',
            'Cannot transfer to the same account',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red[400],
            colorText: Colors.white,
          );
          return;
        }

        await transactionController.addTransfer(
          fromAccountId: _selectedAccountId,
          toAccountId: _selectedToAccountId,
          amount: amount,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          date: _selectedDate,
        );
      } else {
        await transactionController.addTransaction(
          accountId: _selectedAccountId,
          type: _selectedType,
          amount: amount,
          categoryId: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          date: _selectedDate,
        );
      }
    }

    accountController.loadAccounts();
    widget.onSaved();
    Get.back();
  }
}
