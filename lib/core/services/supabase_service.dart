import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SupabaseService extends GetxService {
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  SupabaseClient? _client;
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Check credentials.');
    }
    return _client!;
  }

  bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  final RxBool isConnected = false.obs;
  final RxString lastSyncTime = ''.obs;

  Future<SupabaseService> init() async {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      debugPrint('Warning: Supabase credentials not configured');
      return this;
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    isConnected.value = true;
    return this;
  }

  Future<void> signOut() async {
    if (!isConfigured || _client == null) return;
    await _client!.auth.signOut();
  }

  String? get currentUserId => isConfigured && _client != null ? _client!.auth.currentUser?.id : null;

  bool get isLoggedIn => isConfigured && _client != null && _client!.auth.currentUser != null;

  Future<List<Map<String, dynamic>>> getAccounts(String userId) async {
    if (!isConfigured || _client == null) return [];
    final response = await _client!.from('accounts').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createAccount(String userId, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return null;
    data['user_id'] = userId;
    final response = await _client!.from('accounts').insert(data).select().single();
    return response;
  }

  Future<void> updateAccount(String id, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('accounts').update(data).eq('id', id);
  }

  Future<void> deleteAccount(String id) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('accounts').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    if (!isConfigured || _client == null) return [];
    final response = await _client!.from('transactions').select().eq('user_id', userId).order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createTransaction(String userId, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return null;
    data['user_id'] = userId;
    final response = await _client!.from('transactions').insert(data).select().single();
    return response;
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('transactions').update(data).eq('id', id);
  }

  Future<void> deleteTransaction(String id) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('transactions').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getCategories(String userId) async {
    if (!isConfigured || _client == null) return [];
    final response = await _client!.from('categories').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createCategory(String userId, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return null;
    data['user_id'] = userId;
    final response = await _client!.from('categories').insert(data).select().single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getBudgets(String userId, int month, int year) async {
    if (!isConfigured || _client == null) return [];
    final response = await _client!.from('budgets').select().eq('user_id', userId).eq('month', month).eq('year', year);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createBudget(String userId, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return null;
    data['user_id'] = userId;
    final response = await _client!.from('budgets').insert(data).select().single();
    return response;
  }

  Future<void> updateBudget(String id, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('budgets').update(data).eq('id', id);
  }

  Future<void> deleteBudget(String id) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('budgets').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getLoans(String userId) async {
    if (!isConfigured || _client == null) return [];
    final response = await _client!.from('loans').select().eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createLoan(String userId, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return null;
    data['user_id'] = userId;
    final response = await _client!.from('loans').insert(data).select().single();
    return response;
  }

  Future<void> updateLoan(String id, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('loans').update(data).eq('id', id);
  }

  Future<void> deleteLoan(String id) async {
    if (!isConfigured || _client == null) return;
    await _client!.from('loans').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getLoanPayments(String loanId) async {
    if (!isConfigured || _client == null) return [];
    final response = await _client!.from('loan_payments').select().eq('loan_id', loanId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createLoanPayment(String loanId, Map<String, dynamic> data) async {
    if (!isConfigured || _client == null) return null;
    data['loan_id'] = loanId;
    final response = await _client!.from('loan_payments').insert(data).select().single();
    return response;
  }
}
