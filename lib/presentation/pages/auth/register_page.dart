import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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

  @override
  void initState() {
    super.initState();
    final branchCtrl = Get.isRegistered<BranchController>()
        ? Get.find<BranchController>()
        : Get.put(BranchController(), permanent: true);

    _animationController =
        AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: GetBuilder<AuthController>(
            builder: (controller) {
              return Stack(
                children: [
                  // Background shapes omitted for brevity...

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
                                        validator: (v) => (v == null || v.isEmpty)
                                            ? 'مطلوب'
                                            : (v.length < 2 ? 'قصير جداً' : null),
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
                                        validator: (v) => (v == null || v.isEmpty)
                                            ? 'مطلوب'
                                            : (v.length < 2 ? 'قصير جداً' : null),
                                      ),
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
                                        return 'رقم الهاتف مطلوب';
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

                                // Branch dropdown ... (unchanged)

                                // Passwords ... (unchanged UI/validators)

                                const SizedBox(height: 24),
                                _buildTermsCheckbox(),
                                const SizedBox(height: 32),

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

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('لديك حساب بالفعل؟ ',
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                                    TextButton(
                                      onPressed: () => Get.toNamed(Routes.login),
                                      child: Text('تسجيل دخول',
                                          style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700)),
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
        Text('إنشاء حساب جديد',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text('انضم إلى مجتمع شمرا اليوم',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
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
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                ),
                const TextSpan(text: ' و '),
                TextSpan(
                  text: 'سياسة الخصوصية',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
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
      ShamraSnackBar.show(context: context, message: 'يرجى الموافقة على شروط الخدمة وسياسة الخصوصية', type: SnackBarType.warning);
    }
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedBranch == null) {
      ShamraSnackBar.show(context: context, message: 'الرجاء اختيار الفرع', type: SnackBarType.warning);
      return;
    }

    // NOTE: _phoneE164 تم بناؤه من IntlPhoneField بالفعل بصيغة E.164،
    // نعيد التطبيع مع تمرير ISO2 لزيادة الموثوقية في حال تغيّرت الدولة أو حدثت مسافة/محارف.
    final normalized = PhoneUtils.normalizeToE164(
      _phoneE164?.trim() ?? '',
      defaultIso2: _initialCountryCode,
    );

    if (normalized.isEmpty) {
      ShamraSnackBar.show(context: context, message: 'رقم الهاتف مطلوب', type: SnackBarType.warning);
      return;
    }

    try {
      final auth = Get.find<AuthController>();
      final ok = await auth.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text,
        phoneNumber: normalized,
        branch: _selectedBranch!,
      );

      if (ok) {
        await auth.selectBranchSilent(_selectedBranch!.id);
        ShamraSnackBar.show(context: context, message: 'تم إنشاء الحساب بنجاح. سنرسل لك رمز التحقق', type: SnackBarType.success);
        Get.offAllNamed(Routes.otp, arguments: {'flow': 'verify', 'phone': normalized});
      }
    } catch (_) {
      ShamraSnackBar.show(context: context, message: 'حدث خطأ في إنشاء الحساب', type: SnackBarType.error);
    }
  }
}
