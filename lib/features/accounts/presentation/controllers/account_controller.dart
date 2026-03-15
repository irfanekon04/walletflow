import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/account_model.dart';
import '../../data/repositories/account_repository.dart';

class AccountController extends GetxController {
  final AccountRepository _repository = AccountRepository();

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final RxDouble totalBalance = 0.0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  void loadAccounts() {
    isLoading.value = true;
    accounts.value = _repository.getAll();
    totalBalance.value = _repository.getTotalBalance();
    isLoading.value = false;
  }

  Future<void> addAccount({
    required String name,
    required AccountType type,
    double balance = 0.0,
    double? creditLimit,
    String? icon,
    String? color,
  }) async {
    await _repository.create(
      name: name,
      type: type,
      balance: balance,
      creditLimit: creditLimit,
      icon: icon,
      color: color,
    );
    debugPrint('Account created');
    loadAccounts();
  }

  Future<void> updateAccount(AccountModel account) async {
    await _repository.update(account);
    loadAccounts();
  }

  Future<void> deleteAccount(String id) async {
    await _repository.delete(id);
    loadAccounts();
  }

  Future<void> updateBalance(
    String id,
    double amount, {
    bool isAdd = true,
  }) async {
    await _repository.updateBalance(id, amount, isAdd: isAdd);
    loadAccounts();
  }

  AccountModel? getAccountById(String id) {
    return _repository.getById(id);
  }

  List<AccountModel> getAccountsByType(AccountType type) {
    return accounts.where((acc) => acc.type == type).toList();
  }

  IconData getAccountIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.account_balance_wallet_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'mfs':
        return Icons.phone_android_outlined;
      case 'card':
        return Icons.credit_card_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
