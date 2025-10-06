import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/routes/app_routes.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

/// صفحة تسجيل الدخول (Stateless)
/// -----------------------------
/// - تستخدم [AuthController] للتحكم بالمنطق.
/// - تعرض حقول البريد وكلمة المرور.
/// - تعتمد على Widgets مشتركة لسهولة إعادة الاستخدام.
class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // مفتاح الفورم
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              /// خلفية زخرفية دوائر
              Positioned(
                left: -170,
                top: -250,
                child: Container(
                  width: 500,
                  height: 420,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: 120,
                top: -200,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    color: AppColors.infoLight.withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              /// المحتوى الرئيسي
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 230),

                        /// العنوان
                        const Text(
                          "تسجيل الدخول",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Tajawal",
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF202020),
                          ),
                        ),
                        const SizedBox(height: 8),

                        /// الوصف
                        const Text(
                          "سررنا برؤيتك مجددًا! 🖤",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Tajawal",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF202020),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// حقل البريد الإلكتروني
                        ShamraTextField(
                          hintText: 'أدخل بريدك الإلكتروني',
                          icon: Icons.email_outlined,
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!GetUtils.isEmail(value)) {
                              return 'يرجى إدخال بريد إلكتروني صحيح';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        /// حقل كلمة المرور
                        Obx(() => ShamraTextField(
                          hintText: 'أدخل كلمة المرور',
                          icon: Icons.lock_outlined,
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            onPressed: controller.togglePasswordVisibility,
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        )),

                        const SizedBox(height: 12),

                        /// رابط نسيت كلمة المرور
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // TODO: إضافة صفحة استرجاع كلمة المرور
                            },
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        /// زر تسجيل الدخول
                        Obx(() => ShamraButton(
                          text: 'تسجيل الدخول',
                          onPressed: controller.isLoading
                              ? null
                              : () async {
                            if (_formKey.currentState!.validate()) {
                              await controller.login(
                                controller.emailController.text.trim(),
                                controller.passwordController.text,
                              );
                            }
                          },
                          isLoading: controller.isLoading,
                          icon: Icons.login_rounded,
                        )),

                        const SizedBox(height: 40),

                        /// رابط إلى صفحة التسجيل
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ليس لديك حساب؟ ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.toNamed(Routes.register);
                              },
                              child: Text(
                                'إنشاء حساب',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
