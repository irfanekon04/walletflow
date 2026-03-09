import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  bool _isLogin = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.responsivePadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.screenHeight * 0.1),
                Icon(
                  Icons.account_balance_wallet,
                  size: 80 * context.responsiveFontSize,
                  color: AppColors.primary,
                ),
                SizedBox(height: context.responsiveHeight(0.02)),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48 * context.responsiveFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.005)),
                Text(
                  _isLogin ? 'Welcome back!' : 'Create your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * context.responsiveFontSize,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.05),
                AppTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.responsiveHeight(0.02)),
                AppTextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  label: 'Password',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.responsiveHeight(0.03)),
                Obx(
                  () => AppButton(
                    onPressed: _submit,
                    isLoading: _authController.isLoading.value,
                    label: _isLogin ? 'Sign In' : 'Sign Up',
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.02)),
                if (_authController.errorMessage.value.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(AppDimensions.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.expenseRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                    ),
                    child: Text(
                      _authController.errorMessage.value,
                      style: const TextStyle(color: AppColors.expenseRed),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: context.responsiveHeight(0.03)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(color: Colors.grey[400])),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[400])),
                  ],
                ),
                SizedBox(height: context.responsiveHeight(0.03)),
                Obx(
                  () => AppButton(
                    onPressed: _signInWithGoogle,
                    isLoading: _authController.isLoading.value,
                    isOutlined: true,
                    icon: Icons.g_mobiledata,
                    label: 'Continue with Google',
                  ),
                ),
                SizedBox(height: context.responsiveHeight(0.03)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _authController.errorMessage.value = '';
                        });
                      },
                      child: Text(_isLogin ? 'Sign Up' : 'Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    bool success;
    if (_isLogin) {
      success = await _authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await _authController.register(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (success) {
      SnackbarHelper.success(
        _isLogin ? 'Welcome back!' : 'Account created successfully!',
        title: 'Success',
      );
      Get.offAllNamed('/home');
    } else {
      SnackbarHelper.error(
        'Login failed. Please check your credentials.',
        title: 'Error',
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final success = await _authController.signInWithGoogle();
    if (success) {
      SnackbarHelper.success('Welcome!', title: 'Success');
      Get.offAllNamed('/home');
    }
  }
}
