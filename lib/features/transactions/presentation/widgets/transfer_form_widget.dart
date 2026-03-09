import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../data/models/transaction_model.dart';
import '../controllers/transaction_controller.dart';

class TransferFormWidget extends StatefulWidget {
  final TransactionModel? existingTransfer;
  final Function()? onSaved;

  const TransferFormWidget({super.key, this.existingTransfer, this.onSaved});

  @override
  State<TransferFormWidget> createState() => _TransferFormWidgetState();
}

class _TransferFormWidgetState extends State<TransferFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _fromAccountId;
  String? _toAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingTransfer != null) {
      _amountController.text = widget.existingTransfer!.amount.toString();
      _noteController.text = widget.existingTransfer!.note ?? '';
      _fromAccountId = widget.existingTransfer!.accountId;
      _toAccountId = widget.existingTransfer!.toAccountId;
      _selectedDate = widget.existingTransfer!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fromAccountId == null || _toAccountId == null) {
      SnackbarHelper.error('Please select both accounts', title: 'Error');
      return;
    }

    if (_fromAccountId == _toAccountId) {
      SnackbarHelper.error('Please select different accounts', title: 'Error');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final transactionController = Get.find<TransactionController>();

      if (widget.existingTransfer != null) {
        final oldFromAccountId = widget.existingTransfer!.accountId;
        final oldToAccountId = widget.existingTransfer!.toAccountId;
        final oldAmount = widget.existingTransfer!.amount;

        if (oldToAccountId != null) {
          final accountController = Get.find<AccountController>();
          await accountController.updateBalance(
            oldFromAccountId,
            oldAmount,
            isAdd: true,
          );
          await accountController.updateBalance(
            oldToAccountId,
            oldAmount,
            isAdd: false,
          );

          widget.existingTransfer!.accountId = _fromAccountId!;
          widget.existingTransfer!.toAccountId = _toAccountId!;
          widget.existingTransfer!.amount = amount;
          widget.existingTransfer!.note = _noteController.text.isEmpty
              ? null
              : _noteController.text;
          widget.existingTransfer!.date = _selectedDate;

          await transactionController.updateTransaction(
            widget.existingTransfer!,
          );

          await accountController.updateBalance(
            _fromAccountId!,
            amount,
            isAdd: false,
          );
          await accountController.updateBalance(
            _toAccountId!,
            amount,
            isAdd: true,
          );
        }
      } else {
        await transactionController.addTransaction(
          accountId: _fromAccountId!,
          type: TransactionType.transfer,
          amount: amount,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          date: _selectedDate,
          toAccountId: _toAccountId,
        );
      }

      transactionController.loadTransactions();

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved?.call();
      }
    } catch (e) {
      SnackbarHelper.error('Failed to save transfer: $e', title: 'Error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = context.screenWidth;
    final isCompact = screenWidth < 360;
    final isTablet = context.isTabletWidth;

    return Container(
      constraints: BoxConstraints(maxWidth: isTablet ? 500 : double.infinity),
      padding: EdgeInsets.all(context.responsivePadding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: colorScheme.tertiary,
                    size: isCompact ? 24 : 28,
                  ),
                  SizedBox(width: AppDimensions.paddingS),
                  Text(
                    widget.existingTransfer != null
                        ? 'Edit Transfer'
                        : 'New Transfer',
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.paddingL),

              AppAmountField(controller: _amountController, label: 'Amount'),
              SizedBox(height: AppDimensions.paddingM),

              GetBuilder<AccountController>(
                builder: (accountController) {
                  final accounts = accountController.accounts;

                  return Column(
                    children: [
                      AppDropdown<String>(
                        value: _fromAccountId,
                        label: 'From Account',
                        prefixIcon: const Icon(Icons.arrow_outward),
                        items: accounts
                            .where((a) => a.id != _toAccountId)
                            .map(
                              (account) => DropdownMenuItem(
                                value: account.id,
                                child: Text(
                                  account.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _fromAccountId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an account';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppDimensions.paddingM),
                      AppDropdown<String>(
                        value: _toAccountId,
                        label: 'To Account',
                        prefixIcon: const Icon(Icons.arrow_downward),
                        items: accounts
                            .where((a) => a.id != _fromAccountId)
                            .map(
                              (account) => DropdownMenuItem(
                                value: account.id,
                                child: Text(
                                  account.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _toAccountId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an account';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: AppDimensions.paddingM),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: isCompact ? 12 : 16,
                    ),
                  ),
                  child: Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                    style: TextStyle(fontSize: isCompact ? 14 : 16),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.paddingM),

              AppTextField(
                controller: _noteController,
                maxLines: 2,
                label: 'Note (optional)',
                prefixIcon: const Icon(Icons.note),
              ),
              SizedBox(height: AppDimensions.paddingL),

              AppButton(
                label: AppStrings.save,
                onPressed: _saveTransfer,
                isLoading: _isLoading,
                color: colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
