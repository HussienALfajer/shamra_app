import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../../routes/app_routes.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with TickerProviderStateMixin {
  // مفاتيح وحالات
  final _formKey = GlobalKey<FormState>();

  // Controllers للحقول
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // حالات الحقول
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // إعداد الأنيميشن
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    // التخلص من الـ Controllers لتفادي تسريب الذاكرة
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
      textDirection: TextDirection.rtl, // دعم اللغة العربية
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: GetBuilder<AuthController>(
            builder: (controller) {
              return Stack(
                children: [
                  /// خلفية ديكورية (دوائر ملونة)
                  Positioned(
                    left: -170,
                    top: -225,
                    child: Container(
                      width: 500,
                      height: 420,
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.5),
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
                        color: AppColors.infoLight.withOpacity(0.9),
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
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),

                                /// رأس الصفحة (الشعار + العنوان)
                                _buildHeader(),
                                const SizedBox(height: 40),

                                /// الاسم الأول واسم العائلة
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

                                /// البريد الإلكتروني
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

                                /// رقم الهاتف (اختياري)
                                ShamraTextField(
                                  label: 'رقم الهاتف',
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

                                /// كلمة المرور
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
                                        _isPasswordVisible =
                                        !_isPasswordVisible;
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
                                    if (value.length < 8) {
                                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                /// تأكيد كلمة المرور
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

                                /// مربع اختيار الموافقة على الشروط
                                _buildTermsCheckbox(),

                                const SizedBox(height: 32),

                                /// زر إنشاء حساب
                                Obx(() {
                                  return ShamraButton(
                                    text: 'إنشاء حساب',
                                    onPressed: (controller.isLoading ||
                                        !_acceptTerms)
                                        ? null
                                        : _handleRegister,
                                    isLoading: controller.isLoading,
                                    isSecondary: true,
                                    icon: Icons.person_add_rounded,
                                  );
                                }),

                                const SizedBox(height: 32),

                                /// رابط تسجيل الدخول
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
                                        Get.toNamed(Routes.login);
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
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// رأس الصفحة: شعار + عنوان + وصف
  Widget _buildHeader() {
    return Column(
      children: [
        const ShamraLogo(size: 100, showShadow: true, isGoldVersion: true),
        const SizedBox(height: 20),
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
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// مربع الموافقة على الشروط
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
            activeColor: AppColors.primaryDark,
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

  /// دالة تنفيذ التسجيل
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
          // ✅ نجاح
          ShamraSnackBar.show(
            context: context,
            message: 'تم إنشاء الحساب بنجاح',
            type: SnackBarType.success,
          );
          Get.offAllNamed(Routes.branchSelection);
        }
      } catch (e) {
        // ❌ خطأ
        ShamraSnackBar.show(
          context: context,
          message: 'حدث خطأ في إنشاء الحساب',
          type: SnackBarType.error,
        );
      }
    } else if (!_acceptTerms) {
      // ❗ لم يقبل الشروط
      ShamraSnackBar.show(
        context: context,
        message: 'يرجى الموافقة على شروط الخدمة وسياسة الخصوصية',
        type: SnackBarType.warning,
      );
    }
  }
}
