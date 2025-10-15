import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common_widgets.dart';

/// Forgot Password
/// - يجمع رقم الهاتف
/// - يستدعي /auth/forgot-password لإرسال OTP
/// - ثم يوجّه لصفحة OTP مع flow=reset
class ForgotPasswordPage extends StatelessWidget {
  ForgotPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // تعبئة مسبقة من شاشة تسجيل الدخول إن تم تمرير الرقم
    final args = Get.arguments as Map<String, dynamic>?;
    final prefill = (args?['phone'] ?? '').toString();
    if (prefill.isNotEmpty && _phoneController.text.isEmpty) {
      _phoneController.text = prefill;
    }

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
                  const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
                  const SizedBox(height: 24),
                  const Text(
                    'نسيت كلمة المرور؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'أدخل رقم هاتفك وسنرسل لك رمز التحقق',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  ShamraTextField(
                    hintText: 'أدخل رقم هاتفك',
                    icon: Icons.phone_outlined,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      if (value.length < 8) {
                        return 'يرجى إدخال رقم هاتف صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ShamraButton(
                    text: 'إرسال رمز التحقق',
                    icon: Icons.send,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final phone = _phoneController.text.trim();
                        try {
                          final repo = AuthRepository();
                          await repo.requestPasswordReset(phoneNumber: phone); // ✅ يرسل OTP
                          ShamraSnackBar.show(
                            context: context,
                            message: 'تم إرسال رمز التحقق إلى رقمك',
                            type: SnackBarType.success,
                          );
                          Get.toNamed(
                            Routes.otp,
                            arguments: {'phone': phone, 'flow': 'reset'},
                          );
                        } catch (e) {
                          ShamraSnackBar.show(
                            context: context,
                            message: e.toString(),
                            type: SnackBarType.error,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
