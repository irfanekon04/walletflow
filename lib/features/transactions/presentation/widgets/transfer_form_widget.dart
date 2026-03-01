import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../data/models/transaction_model.dart';
import '../controllers/transaction_controller.dart';

class TransferFormWidget extends StatefulWidget {
  final TransactionModel? existingTransfer;
  final Function()? onSaved;

  const TransferFormWidget({
    super.key,
    this.existingTransfer,
    this.onSaved,
  });

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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
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
      Get.snackbar(
        'Error',
        'Please select both accounts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
      return;
    }

    if (_fromAccountId == _toAccountId) {
      Get.snackbar(
        'Error',
        'Please select different accounts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
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
          await accountController.updateBalance(oldFromAccountId, oldAmount, isAdd: true);
          await accountController.updateBalance(oldToAccountId, oldAmount, isAdd: false);

          widget.existingTransfer!.accountId = _fromAccountId!;
          widget.existingTransfer!.toAccountId = _toAccountId!;
          widget.existingTransfer!.amount = amount;
          widget.existingTransfer!.note = _noteController.text.isEmpty ? null : _noteController.text;
          widget.existingTransfer!.date = _selectedDate;
          
          await transactionController.updateTransaction(widget.existingTransfer!);
          
          await accountController.updateBalance(_fromAccountId!, amount, isAdd: false);
          await accountController.updateBalance(_toAccountId!, amount, isAdd: true);
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
      Get.snackbar(
        'Error',
        'Failed to save transfer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.expenseRed,
        colorText: Colors.white,
      );
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
      constraints: BoxConstraints(
        maxWidth: isTablet ? 500 : double.infinity,
      ),
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
                    widget.existingTransfer != null ? 'Edit Transfer' : 'New Transfer',
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.paddingL),
              
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(fontSize: isCompact ? 16 : 18),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: isCompact ? 12 : 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.paddingM),
              
              GetBuilder<AccountController>(
                builder: (accountController) {
                  final accounts = accountController.accounts;
                  
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _fromAccountId,
                        decoration: InputDecoration(
                          labelText: 'From Account',
                          prefixIcon: const Icon(Icons.arrow_outward),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: isCompact ? 12 : 16,
                          ),
                        ),
                        items: accounts
                            .where((a) => a.id != _toAccountId)
                            .map((account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(
                                    account.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
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
                      DropdownButtonFormField<String>(
                        value: _toAccountId,
                        decoration: InputDecoration(
                          labelText: 'To Account',
                          prefixIcon: const Icon(Icons.arrow_downward),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: isCompact ? 12 : 16,
                          ),
                        ),
                        items: accounts
                            .where((a) => a.id != _fromAccountId)
                            .map((account) => DropdownMenuItem(
                                  value: account.id,
                                  child: Text(
                                    account.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
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
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
              
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                style: TextStyle(fontSize: isCompact ? 14 : 16),
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingM,
                    vertical: isCompact ? 12 : 16,
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.paddingL),
              
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveTransfer,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.save,
                          style: TextStyle(
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
