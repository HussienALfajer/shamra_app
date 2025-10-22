import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter/gestures.dart'; // for TapGestureRecognizer

import '../../../core/constants/colors.dart';
import '../../../data/models/branch.dart';
import '../../../data/utils/phone_utils.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/branch_controller.dart';
import '../../widgets/common_widgets.dart';

/// Register Page (UI only)
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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _phoneE164;
  String _initialCountryCode = 'SY';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;

  Branch? _selectedBranch;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // recognizers for tappable legal links
  late TapGestureRecognizer _tosRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  // Flags from arguments
  bool get _cameFromLogin =>
      (Get.arguments is Map && Get.arguments['cameFrom'] == 'login');
  bool get _allowExitDirect =>
      (Get.arguments is Map && Get.arguments['allowExitDirect'] == true);

  @override
  void initState() {
    super.initState();
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
        );
    _animationController.forward();

    _tosRecognizer = TapGestureRecognizer()..onTap = () => Get.toNamed(Routes.terms);
    _privacyRecognizer = TapGestureRecognizer()..onTap = () => Get.toNamed(Routes.privacy);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _tosRecognizer.dispose();
    _privacyRecognizer.dispose();

    _animation_controller_dispose_safe();
    super.dispose();
  }

  void _animation_controller_dispose_safe() {
    try {
      _animationController.dispose();
    } catch (_) {}
  }

  Future<bool> _onWillPop() async {
    // If we should exit directly to Welcome (second back after a swap)
    if (_allowExitDirect) {
      Get.offAllNamed(Routes.welcome);
      return false;
    }

    // If we actually came from Login, swap back to it once
    if (_cameFromLogin) {
      Get.offNamed(
        Routes.login,
        arguments: {'allowExitDirect': true}, // next back goes to Welcome
      );
      return false;
    }

    // Otherwise go directly to Welcome
    Get.offAllNamed(Routes.welcome);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: GetBuilder<AuthController>(
              builder: (controller) {
                return Stack(
                  children: [
                    // Background shapes omitted...
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

                                  // First & last name vertically stacked
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      ShamraTextField(
                                        label: 'الاسم الأول',
                                        hintText: 'أدخل اسمك الأول',
                                        icon: Icons.person_outline,
                                        controller: _firstNameController,
                                        textCapitalization:
                                        TextCapitalization.words,
                                        isRequired: true,
                                        isSecondary: true,
                                        validator: (v) =>
                                        (v == null || v.isEmpty)
                                            ? 'مطلوب'
                                            : (v.length < 2
                                            ? 'قصير جداً'
                                            : null),
                                      ),
                                      const SizedBox(height: 16),
                                      ShamraTextField(
                                        label: 'اسم العائلة',
                                        hintText: 'أدخل اسم العائلة',
                                        icon: Icons.person_outline,
                                        controller: _lastNameController,
                                        textCapitalization:
                                        TextCapitalization.words,
                                        isRequired: true,
                                        isSecondary: true,
                                        validator: (v) =>
                                        (v == null || v.isEmpty)
                                            ? 'مطلوب'
                                            : (v.length < 2
                                            ? 'قصير جداً'
                                            : null),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

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
                                        final normalized =
                                        PhoneUtils.normalizeIntlParts(
                                          countryDialCode: phone.countryCode,
                                          national: phone.number,
                                          countryIso2: phone.countryISOCode,
                                        );
                                        _phoneE164 = normalized.isNotEmpty
                                            ? normalized
                                            : null;
                                      },
                                      onCountryChanged: (c) =>
                                      _initialCountryCode = c.code,
                                      validator: (phone) {
                                        if (phone == null ||
                                            phone.number.isEmpty) {
                                          return 'رقم الهاتف مطلوب';
                                        }
                                        final normalized =
                                        PhoneUtils.normalizeIntlParts(
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

                                  // Branch dropdown
                                  Obx(() {
                                    final branchCtrl =
                                    Get.find<BranchController>();

                                    if (branchCtrl.isLoading) {
                                      return Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            branchCtrl.errorMessage,
                                            style: const TextStyle(
                                              color: Colors.red,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          OutlinedButton.icon(
                                            onPressed:
                                            branchCtrl.refreshBranches,
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
                                                padding:
                                                EdgeInsetsDirectional
                                                    .only(end: 6),
                                                child: Icon(
                                                  Icons.star_rounded,
                                                  size: 18,
                                                  color: AppColors
                                                      .textSecondary,
                                                ),
                                              ),
                                            Flexible(
                                              child: Text(
                                                b.displayName,
                                                overflow:
                                                TextOverflow.ellipsis,
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
                                          await branchCtrl
                                              .cacheSelectedBranch(b);
                                        }
                                      },
                                      validator: (b) => b == null
                                          ? 'الرجاء اختيار الفرع'
                                          : null,
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
                                      onPressed: () => setState(() =>
                                      _isPasswordVisible =
                                      !_isPasswordVisible),
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
                                      onPressed: () => setState(() =>
                                      _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible),
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

                                  _buildTermsCheckbox(),
                                  const SizedBox(height: 32),

                                  Obx(() {
                                    final isBusy =
                                        Get.find<AuthController>().isLoading;
                                    return ShamraButton(
                                      text: 'إنشاء حساب',
                                      onPressed: (isBusy || !_acceptTerms)
                                          ? null
                                          : _handleRegister,
                                      isLoading: isBusy,
                                      isSecondary: true,
                                      icon: Icons.person_add_rounded,
                                    );
                                  }),

                                  const SizedBox(height: 32),

                                  // Login link: replace current and mark cameFrom=register
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
                                        onPressed: () => Get.offNamed(
                                          Routes.login,
                                          arguments: {'cameFrom': 'register'},
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
            onChanged: (v) => setState(() => _acceptTerms = v ?? false),
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
                  recognizer: _tosRecognizer,
                ),
                const TextSpan(text: ' و '),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: _privacyRecognizer,
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
        message: 'يرجى الموافقة على الشروط',
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

    final normalized = PhoneUtils.normalizeToE164(
      _phoneE164?.trim() ?? '',
      defaultIso2: _initialCountryCode,
    );
    if (normalized.isEmpty) {
      ShamraSnackBar.show(
        context: context,
        message: 'رقم الهاتف مطلوب',
        type: SnackBarType.warning,
      );
      return;
    }

    final auth = Get.find<AuthController>();
    final sent = await auth.sendOtpForRegistration(normalized);
    if (sent) {
      Get.toNamed(
        Routes.otp,
        arguments: {
          'flow': 'register',
          'phone': normalized,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'password': _passwordController.text,
          'branchId': _selectedBranch!.id,
        },
      );
    }
  }
}
