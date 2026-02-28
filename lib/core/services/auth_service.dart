import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  late final FirebaseAuth _auth;

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<AuthService> init() async {
    _auth = FirebaseAuth.instance;
    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
    });
    currentUser.value = _auth.currentUser;
    return this;
  }

  String? get userId => currentUser.value?.uid;
  String? get userEmail => currentUser.value?.email;
  bool get isLoggedIn => currentUser.value != null;

  Future<bool> register(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;
      return credential.user != null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;
      return credential.user != null;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser.value = null;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      isLoading.value = false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e.code);
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email is already registered';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
