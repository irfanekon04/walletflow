import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'supabase_service.dart';

class AuthService extends GetxService {
  final Rx<Session?> currentSession = Rx<Session?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool _checkInitialized() {
    final supabaseService = Get.find<SupabaseService>();
    if (!supabaseService.isInitialized.value) {
      errorMessage.value =
          'Supabase not initialized. Check your configuration.';
      return false;
    }
    return true;
  }

  Future<AuthService> init() async {
    // Mock local session
    return this;
  }

  String? get userId => 'local_user';
  String? get userEmail => 'local@user.com';
  bool get isLoggedIn => true;

  Future<bool> register(String email, String password) async {
    if (!_checkInitialized()) return false;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Get.find<SupabaseService>().client.auth.signUp(
        email: email,
        password: password,
      );

      isLoading.value = false;

      if (response.user != null) {
        return true;
      } else if (response.session == null) {
        errorMessage.value = 'Please check your email to confirm your account';
        return false;
      }
      return false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    if (!_checkInitialized()) return false;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Get.find<SupabaseService>().client.auth
          .signInWithPassword(email: email, password: password);
      debugPrint('Login response success');

      isLoading.value = false;
      return response.user != null;
    } catch (e) {
      debugPrint('Login error: $e');
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    if (!_checkInitialized()) return;
    await Get.find<SupabaseService>().client.auth.signOut();
    currentSession.value = null;
  }

  Future<void> sendPasswordReset(String email) async {
    if (!_checkInitialized()) return;
    try {
      isLoading.value = true;
      await Get.find<SupabaseService>().client.auth.resetPasswordForEmail(
        email,
      );
      isLoading.value = false;
      errorMessage.value =
          'Password reset email sent. Please check your inbox.';
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.toString());
    }
  }

  Future<bool> signInWithGoogle() async {
    if (!_checkInitialized()) return false;
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Get.find<SupabaseService>().client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.walletflow.app://login-callback',
      );

      isLoading.value = true;
      return true;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Google sign-in failed. Please try again.';
      return false;
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('initialize') || error.contains('null')) {
      return 'Supabase client error. Please check configuration.';
    }
    if (error.contains('invalid_email')) {
      return 'Invalid email address';
    } else if (error.contains('invalid_credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('user_not_found')) {
      return 'No user found with this email';
    } else if (error.contains('email_not_confirmed')) {
      return 'Please confirm your email address';
    } else if (error.contains('weak_password')) {
      return 'Password is too weak';
    } else if (error.contains('email_already_exists') ||
        error.contains('email_already_registered')) {
      return 'Email is already registered';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection';
    }
    return 'An error occurred. Please try again';
  }
}
