import 'dart:io';
import 'dart:typed_data';
import 'package:csv/csv.dart';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_saver/file_saver.dart';
import '../database/database_service.dart';
import '../widgets/snackbar_helper.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/transactions/data/models/transaction_model.dart';
import '../../features/transactions/data/models/category_model.dart';

class ExportService {
  
  Future<String> exportTransactionsToCSV() async {
    final transactions = DatabaseService.transactions.values.toList();
    final accounts = DatabaseService.accounts.values.toList();
    final categories = DatabaseService.categories.values.toList();
    
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    final List<List<dynamic>> csvData = [
      ['Date', 'Type', 'Category', 'Account', 'To Account', 'Amount', 'Note']
    ];
    
    final dateFormat = DateFormat('yyyy-MM-dd');
    
    for (final transaction in transactions) {
      final account = _getAccountById(accounts, transaction.accountId);
      final category = _getCategoryById(categories, transaction.categoryId);
      final toAccount = transaction.toAccountId != null 
          ? _getAccountById(accounts, transaction.toAccountId!) 
          : null;
      
      csvData.add([
        dateFormat.format(transaction.date),
        _getTransactionTypeName(transaction.type),
        category?.name ?? 'Uncategorized',
        account?.name ?? 'Unknown',
        toAccount?.name ?? '',
        transaction.amount.toStringAsFixed(2),
        transaction.note ?? '',
      ]);
    }
    
    return const ListToCsvConverter().convert(csvData);
  }
  
  Future<File> saveCSVToFile(String csvContent) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/walletflow_export_$timestamp.csv');
    await file.writeAsString(csvContent);
    return file;
  }
  
  Future<void> saveToDownloads() async {
    try {
      final csvContent = await exportTransactionsToCSV();
      
      if (csvContent.split('\n').length <= 1) {
        SnackbarHelper.warning('No transactions to export', title: 'No Data');
        return;
      }
      
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'walletflow_export_$timestamp.csv';
      
      final Uint8List bytes = Uint8List.fromList(csvContent.codeUnits);
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        mimeType: MimeType.csv,
      );
      
      SnackbarHelper.success('File saved: $fileName', title: 'Export Successful');
    } catch (e) {
      SnackbarHelper.error('Unable to export: $e', title: 'Export Failed');
    }
  }
  
  Future<void> exportAndShare() async {
    await saveToDownloads();
  }
  
  AccountModel? _getAccountById(List<AccountModel> accounts, String id) {
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
  
  CategoryModel? _getCategoryById(List<CategoryModel> categories, String? id) {
    if (id == null) return null;
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  String _getTransactionTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}
