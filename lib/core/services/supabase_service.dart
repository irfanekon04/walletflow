import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class SupabaseService extends GetxService {
  static const String supabaseUrl = 'https://nfsbbmovahchesqvvida.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5mc2JibW92YWhjaGVzcXZ2aWRhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyNTM1MjMsImV4cCI6MjA4NzgyOTUyM30.RZgudOtJWnOPEQDJosr7EeevxXwH6Tgkk0YuUyXBxEU';

  late final SupabaseClient client;
  
  final RxBool isConnected = false.obs;
  final RxString lastSyncTime = ''.obs;

  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    client = Supabase.instance.client;
    return this;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  String? get currentUserId => client.auth.currentUser?.id;

  bool get isLoggedIn => client.auth.currentUser != null;

  // Account operations
  Future<List<Map<String, dynamic>>> getAccounts(String userId) async {
    final response = await client
        .from('accounts')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createAccount(String userId, Map<String, dynamic> data) async {
    data['user_id'] = userId;
    final response = await client.from('accounts').insert(data).select().single();
    return response;
  }

  Future<void> updateAccount(String id, Map<String, dynamic> data) async {
    await client.from('accounts').update(data).eq('id', id);
  }

  Future<void> deleteAccount(String id) async {
    await client.from('accounts').delete().eq('id', id);
  }

  // Transaction operations
  Future<List<Map<String, dynamic>>> getTransactions(String userId) async {
    final response = await client
        .from('transactions')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createTransaction(String userId, Map<String, dynamic> data) async {
    data['user_id'] = userId;
    final response = await client.from('transactions').insert(data).select().single();
    return response;
  }

  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    await client.from('transactions').update(data).eq('id', id);
  }

  Future<void> deleteTransaction(String id) async {
    await client.from('transactions').delete().eq('id', id);
  }

  // Category operations
  Future<List<Map<String, dynamic>>> getCategories(String userId) async {
    final response = await client
        .from('categories')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createCategory(String userId, Map<String, dynamic> data) async {
    data['user_id'] = userId;
    final response = await client.from('categories').insert(data).select().single();
    return response;
  }

  // Budget operations
  Future<List<Map<String, dynamic>>> getBudgets(String userId, int month, int year) async {
    final response = await client
        .from('budgets')
        .select()
        .eq('user_id', userId)
        .eq('month', month)
        .eq('year', year);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createBudget(String userId, Map<String, dynamic> data) async {
    data['user_id'] = userId;
    final response = await client.from('budgets').insert(data).select().single();
    return response;
  }

  Future<void> updateBudget(String id, Map<String, dynamic> data) async {
    await client.from('budgets').update(data).eq('id', id);
  }

  Future<void> deleteBudget(String id) async {
    await client.from('budgets').delete().eq('id', id);
  }

  // Loan operations
  Future<List<Map<String, dynamic>>> getLoans(String userId) async {
    final response = await client
        .from('loans')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createLoan(String userId, Map<String, dynamic> data) async {
    data['user_id'] = userId;
    final response = await client.from('loans').insert(data).select().single();
    return response;
  }

  Future<void> updateLoan(String id, Map<String, dynamic> data) async {
    await client.from('loans').update(data).eq('id', id);
  }

  Future<void> deleteLoan(String id) async {
    await client.from('loans').delete().eq('id', id);
  }

  // Loan Payment operations
  Future<List<Map<String, dynamic>>> getLoanPayments(String loanId) async {
    final response = await client
        .from('loan_payments')
        .select()
        .eq('loan_id', loanId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> createLoanPayment(String loanId, Map<String, dynamic> data) async {
    data['loan_id'] = loanId;
    final response = await client.from('loan_payments').insert(data).select().single();
    return response;
  }
}
