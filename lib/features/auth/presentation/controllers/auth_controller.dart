import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/sync_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isLoggedIn => _authService.isLoggedIn;
  String? get userEmail => _authService.userEmail;
  String? get userId => _authService.userId;

  Future<bool> register(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final success = await _authService.register(email, password);
    
    if (success) {
      final syncService = Get.find<SyncService>();
      await syncService.enableSync();
    }
    
    isLoading.value = false;
    return success;
  }

  Future<bool> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final success = await _authService.login(email, password);
    
    
    if (success) {
      final syncService = Get.find<SyncService>();
      await syncService.enableSync();
    }
    
    isLoading.value = false;
    return success;
  }

  Future<void> logout() async {
    isLoading.value = true;
    
    await _authService.logout();
    await _supabaseService.signOut();
    
    final syncService = Get.find<SyncService>();
    await syncService.disableSync();
    
    isLoading.value = false;
    Get.offAllNamed('/login');
  }

  Future<bool> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    final success = await _authService.signInWithGoogle();
    
    isLoading.value = false;
    return success;
  }

  String get error => _authService.errorMessage.value;
}
