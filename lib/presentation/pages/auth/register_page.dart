import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/branch.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/branch_controller.dart';
import '../../widgets/common_widgets.dart';

/// Register Page (UI only)
/// - No email field (phone is mandatory)
/// - Uses IntlPhoneField for country picker + flags + E.164 phone
/// - Caches selected Branch pre-auth; server selection happens post-register
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();

  // Field controllers
  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _passwordController  = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Phone (E.164)
  String? _phoneE164;
  String _initialCountryCode = 'SY'; // 'NL' لو بدك هولندا افتراضيًا

  // Field states
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  // Branch selection
  Branch? _selectedBranch;

  // Animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
// داخل build:
    final branchCtrl = Get.isRegistered<BranchController>()
        ? Get.find<BranchController>()
        : Get.put(BranchController(), permanent: true);

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branchCtrl = Get.find<BranchController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: GetBuilder<AuthController>(
            builder: (controller) {
              return Stack(
                children: [
                  // Decorative background
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

                  // Content
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
                                _buildHeader(),
                                const SizedBox(height: 40),

                                // First/Last name
                                Row(
                                  children: [
                                    Expanded(
                                      child: ShamraTextField(
                                        label: 'الاسم الأول',
                                        hintText: 'أدخل اسمك الأول',
                                        icon: Icons.person_outline,
                                        controller: _firstNameController,
                                        textCapitalization: TextCapitalization.words,
                                        isRequired: true,
                                        isSecondary: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'مطلوب';
                                          if (value.length < 2) return 'قصير جداً';
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
                                        textCapitalization: TextCapitalization.words,
                                        isRequired: true,
                                        isSecondary: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'مطلوب';
                                          if (value.length < 2) return 'قصير جداً';
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Phone (mandatory)
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: IntlPhoneField(
                                    decoration: const InputDecoration(
                                      labelText: 'رقم الهاتف',
                                      border: OutlineInputBorder(),
                                    ),
                                    initialCountryCode: _initialCountryCode,
                                    showCountryFlag: true,
                                    showDropdownIcon: true,
                                    dropdownIconPosition: IconPosition.trailing,
                                    disableLengthCheck: true,
                                    onChanged: (phone) {
                                      _phoneE164 = phone.completeNumber; // +9639xxxxxx
                                    },
                                    onCountryChanged: (country) {
                                      _initialCountryCode = country.code;
                                    },
                                    validator: (phone) {
                                      if (phone == null || phone.number.isEmpty) {
                                        return 'رقم الهاتف مطلوب';
                                      }
                                      if (phone.number.length < 8) {
                                        return 'يرجى إدخال رقم هاتف صحيح';
                                      }
                                      return null;
                                    },
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Branch dropdown — caches selection immediately
                                Obx(() {
                                  final branchCtrl = Get.find<BranchController>();

                                  if (branchCtrl.isLoading) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  if (branchCtrl.errorMessage.isNotEmpty) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          branchCtrl.errorMessage,
                                          style: const TextStyle(color: Colors.red, fontSize: 13),
                                        ),
                                        const SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          onPressed: branchCtrl.refreshBranches,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('إعادة المحاولة'),
                                        ),
                                      ],
                                    );
                                  }

                                  final items = branchCtrl.branches
                                      .map(
                                        (b) => DropdownMenuItem<Branch>(
                                      value: b,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (b.isMainBranch)
                                            const Padding(
                                              padding: EdgeInsetsDirectional.only(end: 6),
                                              child: Icon(
                                                Icons.star_rounded,
                                                size: 18,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          Flexible(
                                            child: Text(
                                              b.displayName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      .toList();

                                  return DropdownButtonFormField<Branch>(
                                    value: _selectedBranch,
                                    items: items,
                                    onChanged: (b) async {
                                      setState(() => _selectedBranch = b);
                                      if (b != null) {
                                        await branchCtrl.cacheSelectedBranch(b);
                                      }
                                    },
                                    validator: (b) => b == null ? 'الرجاء اختيار الفرع' : null,
                                    decoration: const InputDecoration(
                                      labelText: 'اختر الفرع',
                                      border: OutlineInputBorder(),
                                    ),
                                  );
                                }),

                                const SizedBox(height: 20),

                                // Password
                                ShamraTextField(
                                  label: 'كلمة المرور',
                                  hintText: 'أنشئ كلمة مرور قوية',
                                  icon: Icons.lock_outlined,
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  isRequired: true,
                                  isSecondary: true,
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
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

                                // Confirm password
                                ShamraTextField(
                                  label: 'تأكيد كلمة المرور',
                                  hintText: 'أعد إدخال كلمة المرور',
                                  icon: Icons.lock_outlined,
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  isRequired: true,
                                  isSecondary: true,
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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

                                // Terms checkbox
                                _buildTermsCheckbox(),

                                const SizedBox(height: 32),

                                // Register button
                                Obx(() {
                                  final isBusy = Get.find<AuthController>().isLoading;
                                  return ShamraButton(
                                    text: 'إنشاء حساب',
                                    onPressed: (isBusy || !_acceptTerms) ? null : _handleRegister,
                                    isLoading: isBusy,
                                    isSecondary: true,
                                    icon: Icons.person_add_rounded,
                                  );
                                }),

                                const SizedBox(height: 32),

                                // Go to login
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
                                      onPressed: () => Get.toNamed(Routes.login),
                                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4)),
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

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            activeColor: AppColors.primaryDark,
            checkColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
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

  Future<void> _handleRegister() async {
    if (!_acceptTerms) {
      ShamraSnackBar.show(
        context: context,
        message: 'يرجى الموافقة على شروط الخدمة وسياسة الخصوصية',
        type: SnackBarType.warning,
      );
      return;
    }

    if (_formKey.currentState?.validate() != true) return;

    if (_selectedBranch == null) {
      ShamraSnackBar.show(
        context: context,
        message: 'الرجاء اختيار الفرع',
        type: SnackBarType.warning,
      );
      return;
    }

    final phoneNumber = _phoneE164?.trim() ?? '';
    if (phoneNumber.isEmpty) {
      ShamraSnackBar.show(
        context: context,
        message: 'رقم الهاتف مطلوب',
        type: SnackBarType.warning,
      );
      return;
    }

    try {
      final authController = Get.find<AuthController>();
      final success = await authController.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text,
        phoneNumber: phoneNumber,
        branch: _selectedBranch!,
      );

      if (success) {
        await authController.selectBranchSilent(_selectedBranch!.id);

        ShamraSnackBar.show(
          context: context,
          message: 'تم إنشاء الحساب بنجاح. سنرسل لك رمز التحقق',
          type: SnackBarType.success,
        );

        Get.offAllNamed(
          Routes.otp,
          arguments: {'flow': 'register', 'phone': phoneNumber},
        );
      }
    } catch (e) {
      ShamraSnackBar.show(
        context: context,
        message: 'حدث خطأ في إنشاء الحساب',
        type: SnackBarType.error,
      );
    }
  }
}
