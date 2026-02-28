import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/account_model.dart';

class AccountRepository {
  final _uuid = const Uuid();

  Box<AccountModel> get _box => Hive.box<AccountModel>('accounts');

  List<AccountModel> getAll() {
    return _box.values.toList();
  }

  AccountModel? getById(String id) {
    try {
      return _box.values.firstWhere((acc) => acc.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<AccountModel> create({
    required String name,
    required AccountType type,
    double balance = 0.0,
    double? creditLimit,
    String? icon,
    String? color,
  }) async {
    final now = DateTime.now();
    final account = AccountModel(
      id: _uuid.v4(),
      name: name,
      type: type,
      balance: balance,
      creditLimit: creditLimit,
      icon: icon ?? _getDefaultIcon(type),
      color: color ?? _getDefaultColor(type),
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(account.id, account);
    debugPrint('Account created: ${account.id}');
    return account;
  }

  Future<AccountModel> update(AccountModel account) async {
    account.updatedAt = DateTime.now();
    account.isSynced = false;
    await _box.put(account.id, account);
    return account;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> updateBalance(
    String id,
    double amount, {
    bool isAdd = true,
  }) async {
    final account = getById(id);
    if (account != null) {
      account.balance = isAdd
          ? account.balance + amount
          : account.balance - amount;
      account.updatedAt = DateTime.now();
      account.isSynced = false;
      await _box.put(account.id, account);
    }
  }

  double getTotalBalance() {
    double total = 0;
    for (final account in getAll()) {
      if (account.type != AccountType.creditCard) {
        total += account.balance;
      } else {
        total -= account.balance;
      }
    }
    return total;
  }

  String _getDefaultIcon(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return 'wallet';
      case AccountType.bank:
        return 'account_balance';
      case AccountType.mfs:
        return 'phone_android';
      case AccountType.creditCard:
        return 'credit_card';
    }
  }

  String _getDefaultColor(AccountType type) {
    switch (type) {
      case AccountType.cash:
        return '#4CAF50';
      case AccountType.bank:
        return '#2196F3';
      case AccountType.mfs:
        return '#9C27B0';
      case AccountType.creditCard:
        return '#FF9800';
    }
  }
}
