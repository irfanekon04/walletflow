import 'dart:io';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database_service.dart';
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
    // Get Downloads directory
    Directory? directory;
    
    if (Platform.isAndroid) {
      // Try to get external storage directory (Downloads folder)
      directory = await getExternalStorageDirectory();
      if (directory != null) {
        // Navigate to Downloads folder
        final downloadsPath = directory.path.replaceAll('/Android/data/com.walletflow.app/files', '/Download');
        directory = Directory(downloadsPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }
    }
    
    // Fallback to app documents directory
    directory ??= await getApplicationDocumentsDirectory();
    
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/walletflow_export_$timestamp.csv');
    await file.writeAsString(csvContent);
    return file;
  }
  
  Future<void> saveToDownloads() async {
    try {
      // Request storage permission for Android
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          // Try manage external storage for broader access
          await Permission.manageExternalStorage.request();
        }
      }
      
      final csvContent = await exportTransactionsToCSV();
      
      if (csvContent.split('\n').length <= 1) {
        Get.snackbar(
          'No Data',
          'No transactions to export',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      final file = await saveCSVToFile(csvContent);
      
      Get.snackbar(
        'Export Successful',
        'Saved to: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Unable to export: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
