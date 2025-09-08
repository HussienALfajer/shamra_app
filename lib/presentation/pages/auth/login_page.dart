import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/routes/app_routes.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GetBuilder<AuthController>(
                builder: (controller) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Logo and Header Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: ShamraLogo(
                              size: 120,
                              showShadow: true,
                              isGoldVersion: false,
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Form Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Email Field
                              ShamraTextField(
                                label: 'البريد الإلكتروني',
                                hintText: 'أدخل بريدك الإلكتروني',
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                isRequired: true,
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

                              // Password Field
                              ShamraTextField(
                                label: 'كلمة المرور',
                                hintText: 'أدخل كلمة المرور',
                                icon: Icons.lock_outlined,
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                isRequired: true,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _isPasswordVisible
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

                              const SizedBox(height: 12),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    // Navigate to forgot password
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                  child: Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Login Button
                              Obx(() {
                                return ShamraButton(
                                  text: 'تسجيل الدخول',
                                  onPressed: controller.isLoading
                                      ? null
                                      : _handleLogin,
                                  isLoading: controller.isLoading,
                                  icon: Icons.login_rounded,
                                );
                              }),

                              const SizedBox(height: 40),

                              // Sign Up Link
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
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                    ),
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
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(
          child: ShamraButton(
            text: 'جوجل',
            onPressed: () {
              // Handle Google login
              ShamraSnackBar.show(
                context: context,
                message: 'سيتم إضافة تسجيل الدخول عبر جوجل قريباً',
                type: SnackBarType.info,
              );
            },
            isOutlined: true,
            icon: Icons.g_mobiledata_rounded,
            height: 50,
          ),
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authController = Get.find<AuthController>();

      try {
        final success = await authController.login(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (success) {
          ShamraSnackBar.show(
            context: context,
            message: 'تم تسجيل الدخول بنجاح',
            type: SnackBarType.success,
          );
          Get.offAllNamed('/branch-selection');
        }
      } catch (e) {
        ShamraSnackBar.show(
          context: context,
          message: 'حدث خطأ في تسجيل الدخول',
          type: SnackBarType.error,
        );
      }
    }
  }
}
