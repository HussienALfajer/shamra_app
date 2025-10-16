import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/utils/phone_utils.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common_widgets.dart';

/// Reset Password Page (UI only)
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final phoneNumber = args?['phone'] as String? ?? '';
    final otp = args?['otp'] as String? ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  const Icon(Icons.lock_outline, size: 80, color: AppColors.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'إعادة تعيين كلمة المرور',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Text('أدخل كلمة مرور جديدة لحسابك',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 40),

                  ShamraTextField(
                    hintText: 'كلمة المرور الجديدة',
                    icon: Icons.lock_outlined,
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'يرجى إدخال كلمة المرور';
                      if (v.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  ShamraTextField(
                    hintText: 'تأكيد كلمة المرور',
                    icon: Icons.lock_outlined,
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondary),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'يرجى تأكيد كلمة المرور';
                      if (v != _passwordController.text) return 'كلمات المرور غير متطابقة';
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),
                  ShamraButton(
                    text: 'تغيير كلمة المرور',
                    icon: Icons.check,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : () => _handleResetPassword(phoneNumber, otp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword(String phoneNumber, String otp) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final repo = AuthRepository();
      await repo.resetPassword(
        phoneNumber: PhoneUtils.normalizeToE164(phoneNumber),
        newPassword: _passwordController.text,
        otp: otp,
      );

      ShamraSnackBar.show(context: context, message: 'تم تغيير كلمة المرور بنجاح', type: SnackBarType.success);
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(Routes.login);
    } catch (e) {
      ShamraSnackBar.show(context: context, message: 'فشل تغيير كلمة المرور: ${e.toString()}', type: SnackBarType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
