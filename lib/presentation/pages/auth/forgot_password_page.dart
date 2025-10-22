import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/constants/colors.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/utils/phone_utils.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/common_widgets.dart';

/// Forgot Password Page (UI only)
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String? _phoneE164;
  final _auth = Get.find<AuthController>();
  String _initialCountryCode = 'SY';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final prefill = (args?['phone'] ?? '').toString();
    if (prefill.isNotEmpty) {
      _phoneE164 = prefill;
      if (prefill.startsWith('+963')) _initialCountryCode = 'SY';
    }
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
                          countryDialCode: phone.countryCode,   // e.g. "+49"
                          national: phone.number,                // typed NSN
                          countryIso2: phone.countryISOCode,     // e.g. "DE"
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

                  const SizedBox(height: 32),
                  ShamraButton(
                    text: 'إرسال رمز التحقق',
                    icon: Icons.send,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _handleSendOtp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

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

    setState(() => _isLoading = true);
    try {
      final ok = await _auth.requestPasswordReset(normalized);
      if (ok) {
        Get.toNamed(
          Routes.otp,
          arguments: {'phone': normalized, 'flow': 'reset'},
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
