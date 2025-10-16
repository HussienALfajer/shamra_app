import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:shamra_app/routes/app_routes.dart';
import '../../../core/constants/colors.dart';
import '../../../data/utils/phone_utils.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

/// Login Page (UI only)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController(); // local controller
  String? _phoneE164;
  String _initialCountryCode = 'SY';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 230),
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

                    // Phone
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: IntlPhoneField(
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف ',
                          border: OutlineInputBorder(),
                        ),
                        initialCountryCode: _initialCountryCode,
                        showCountryFlag: true,
                        showDropdownIcon: true,
                        dropdownIconPosition: IconPosition.trailing,
                        disableLengthCheck: true,
                        onChanged: (phone) {
                          final normalized = PhoneUtils.normalizeIntlParts(
                            countryDialCode: phone.countryCode,
                            national: phone.number,
                            countryIso2: phone.countryISOCode,
                          );
                          _phoneE164 = normalized.isNotEmpty ? normalized : null;
                        },
                        onCountryChanged: (c) => _initialCountryCode = c.code,
                        validator: (phone) {
                          if (phone == null || phone.number.isEmpty) {
                            return 'يرجى إدخال رقم الهاتف';
                          }
                          final normalized = PhoneUtils.normalizeIntlParts(
                            countryDialCode: phone.countryCode,
                            national: phone.number,
                            countryIso2: phone.countryISOCode,
                          );
                          if (!PhoneUtils.isValidE164(normalized)) {
                            return 'يرجى إدخال رقم دولي صحيح بصيغة +XXXXXXXX';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password (local controller)
                    Obx(
                          () => ShamraTextField(
                        hintText: 'أدخل كلمة المرور',
                        icon: Icons.lock_outlined,
                        controller: _passwordController,
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
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Get.toNamed(
                          Routes.forgotPassword,
                          arguments: {
                            'phone': PhoneUtils.normalizeToE164(
                              _phoneE164?.trim() ?? '',
                              defaultIso2: _initialCountryCode,
                            )
                          },
                        ),
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

                    // Login btn
                    Obx(
                          () => ShamraButton(
                        text: 'تسجيل الدخول',
                        onPressed: controller.isLoading
                            ? null
                            : () async {
                          if (_formKey.currentState!.validate()) {
                            final normalized = PhoneUtils.normalizeToE164(
                              _phoneE164?.trim() ?? '',
                              defaultIso2: _initialCountryCode,
                            );
                            if (normalized.isEmpty) {
                              ShamraSnackBar.show(
                                context: context,
                                message: 'يرجى إدخال رقم الهاتف',
                                type: SnackBarType.warning,
                              );
                              return;
                            }
                            await controller.login(
                              normalized,
                              _passwordController.text,
                            );
                          }
                        },
                        isLoading: controller.isLoading,
                        icon: Icons.login_rounded,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Register link
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
                          onPressed: () => Get.toNamed(Routes.register),
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
        ),
      ),
    );
  }
}
