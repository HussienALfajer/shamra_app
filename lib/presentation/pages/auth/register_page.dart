import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_forward_ios, color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GetBuilder<AuthController>(
                builder: (controller) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Header Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildHeader(),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Form Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              // Name Fields Row
                              Row(
                                children: [
                                  Expanded(
                                    child: ShamraTextField(
                                      label: 'الاسم الأول',
                                      hintText: 'أدخل اسمك الأول',
                                      icon: Icons.person_outline,
                                      controller: _firstNameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      isRequired: true,
                                      isSecondary: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'مطلوب';
                                        }
                                        if (value.length < 2) {
                                          return 'قصير جداً';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ShamraTextField(
                                      label: 'اسم العائلة',
                                      hintText: 'أدخل اسم العائلة',
                                      icon: Icons.person_outline,
                                      controller: _lastNameController,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      isRequired: true,
                                      isSecondary: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'مطلوب';
                                        }
                                        if (value.length < 2) {
                                          return 'قصير جداً';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Email Field
                              ShamraTextField(
                                label: 'البريد الإلكتروني',
                                hintText: 'أدخل بريدك الإلكتروني',
                                icon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                isRequired: true,
                                isSecondary: true,
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

                              // Phone Field
                              ShamraTextField(
                                label: 'رقم الهاتف (اختياري)',
                                hintText: 'أدخل رقم هاتفك',
                                icon: Icons.phone_outlined,
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                isSecondary: true,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      value.length < 8) {
                                    return 'يرجى إدخال رقم هاتف صحيح';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Password Field
                              ShamraTextField(
                                label: 'كلمة المرور',
                                hintText: 'أنشئ كلمة مرور قوية',
                                icon: Icons.lock_outlined,
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                isRequired: true,
                                isSecondary: true,
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
                                    return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Confirm Password Field
                              ShamraTextField(
                                label: 'تأكيد كلمة المرور',
                                hintText: 'أعد إدخال كلمة المرور',
                                icon: Icons.lock_outlined,
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                isRequired: true,
                                isSecondary: true,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى تأكيد كلمة المرور';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'كلمات المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Terms and Conditions
                              _buildTermsCheckbox(),

                              const SizedBox(height: 32),

                              // Register Button
                              Obx(() {
                                return ShamraButton(
                                  text: 'إنشاء حساب',
                                  onPressed:
                                      (controller.isLoading || !_acceptTerms)
                                      ? null
                                      : _handleRegister,
                                  isLoading: controller.isLoading,
                                  isSecondary: true,
                                  icon: Icons.person_add_rounded,
                                );
                              }),

                              const SizedBox(height: 32),

                              // Sign In Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'لديك حساب بالفعل؟ ',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                    ),
                                    child: Text(
                                      'تسجيل دخول',
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Shamra Logo - Gold version for register
        const ShamraLogo(size: 100, showShadow: true, isGoldVersion: true),

        const SizedBox(height: 20),

        // Welcome Text
        Text(
          'إنشاء حساب جديد',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'انضم إلى مجتمع شمرا اليوم',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: AppColors.secondary,
            checkColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'أوافق على '),
                TextSpan(
                  text: 'شروط الخدمة',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const TextSpan(text: ' و '),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      final authController = Get.find<AuthController>();

      try {
        final success = await authController.register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

        if (success) {
          ShamraSnackBar.show(
            context: context,
            message: 'تم إنشاء الحساب بنجاح',
            type: SnackBarType.success,
          );
          Get.offAllNamed('/branch-selection');
        }
      } catch (e) {
        ShamraSnackBar.show(
          context: context,
          message: 'حدث خطأ في إنشاء الحساب',
          type: SnackBarType.error,
        );
      }
    } else if (!_acceptTerms) {
      ShamraSnackBar.show(
        context: context,
        message: 'يرجى الموافقة على شروط الخدمة وسياسة الخصوصية',
        type: SnackBarType.warning,
      );
    }
  }
}
