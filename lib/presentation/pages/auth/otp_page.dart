///////////////////////////////////////////////////////////////////
// lib/presentation/pages/auth/otp_page.dart
import 'dart:async'; // cooldown timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamra_app/routes/app_routes.dart';

import '../../../core/constants/colors.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/auth_controller.dart';

/// OTP Verification Page
/// Flows:
/// - 'verify' (after register) → verify then go to Main
/// - 'register' (explicit registration flow with registrationToken) → verify OTP then register
/// - 'reset' (forgot password) → verify OTP (server-side check only), then navigate to ResetPassword
///
/// Extras:
/// - Resend OTP with 120s cooldown. Calls:
///   - registration/verify flows → `sendOtpForRegistration`
///   - reset flow → `requestPasswordReset`
class OtpPage extends StatefulWidget {
  final String? phone;
  final String? flow; // 'verify' or 'register' or 'reset'
  const OtpPage({super.key, this.phone, this.flow});

  static OtpPage fromArgs() {
    final args = (Get.arguments is Map) ? Map<String, dynamic>.from(Get.arguments) : const {};
    return OtpPage(
      phone: (args['phone'] ?? '').toString(),
      flow: (args['flow'] ?? 'verify').toString(),
    );
  }

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _auth = Get.find<AuthController>();

  // --- OTP boxes state ---
  static const _len = 4;
  late final List<TextEditingController> _tcs;
  late final List<FocusNode> _fns;
  late final List<bool> _filled;

  // --- UI/logic state ---
  bool _isVerifying = false;
  String? _error;

  // --- resend cooldown ---
  Timer? _timer;
  int _cooldown = 0; // seconds remaining before allowing resend

  String get _phone {
    final argsPhone = (Get.arguments is Map) ? (Get.arguments['phone']?.toString() ?? '') : '';
    final wPhone = widget.phone ?? '';
    // Prefer arguments if provided
    return (argsPhone.isNotEmpty) ? argsPhone : wPhone;
  }

  String get _flow {
    final argsFlow = (Get.arguments is Map) ? (Get.arguments['flow']?.toString() ?? '') : '';
    final wFlow = widget.flow ?? '';
    // Prefer arguments if provided
    if (argsFlow.isNotEmpty) return argsFlow;
    if (wFlow.isNotEmpty) return wFlow;
    return 'verify';
  }

  @override
  void initState() {
    super.initState();
    _tcs = List.generate(_len, (_) => TextEditingController());
    _fns = List.generate(_len, (_) => FocusNode());
    _filled = List.generate(_len, (_) => false);

    // Start cooldown immediately since an OTP was just sent before landing here
    _startCooldown(120);
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _tcs) c.dispose();
    for (final f in _fns) f.dispose();
    super.dispose();
  }

  // --- helpers: otp editing & paste ---
  void _onChanged(int idx, String v) {
    if (v.length > 1) {
      final digits = v.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < _len; i++) {
        _tcs[i].text = i < digits.length ? digits[i] : '';
        _filled[i] = _tcs[i].text.isNotEmpty;
      }
      setState(() {});
    } else {
      setState(() => _filled[idx] = v.isNotEmpty);
      if (v.isNotEmpty && idx < _len - 1) _fns[idx + 1].requestFocus();
      if (v.isEmpty && idx > 0) _fns[idx - 1].requestFocus();
    }
    if (_collect().length == _len) {
      _verify();
    }
  }

  Future<void> _clearAll() async {
    for (final c in _tcs) {
      c.clear();
    }
    setState(() {
      for (var i = 0; i < _filled.length; i++) _filled[i] = false;
      _error = null;
    });
    _fns.first.requestFocus();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = (data?.text ?? '').replaceAll(RegExp(r'\D'), '');
    if (text.isEmpty) return;
    final digits = text.length > _len ? text.substring(0, _len) : text;
    for (var i = 0; i < _len; i++) {
      _tcs[i].text = i < digits.length ? digits[i] : '';
      _filled[i] = _tcs[i].text.isNotEmpty;
    }
    setState(() {});
    if (digits.length == _len) _verify();
  }

  String _collect() => _tcs.map((c) => c.text).join();

  // --- resend cooldown helpers ---
  void _startCooldown([int seconds = 120]) {
    setState(() => _cooldown = seconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _resend() async {
    // Prevent spamming or conflicts with verify
    if (_cooldown > 0 || _isVerifying) return;

    try {
      setState(() {
        _isVerifying = true;
        _error = null;
      });

      bool ok = false;

      if (_flow == 'reset') {
        // Forgot-password flow → resend reset OTP
        ok = await _auth.requestPasswordReset(_phone);
      } else {
        // Registration/verify flows → resend registration OTP
        ok = await _auth.sendOtpForRegistration(_phone);
      }

      if (!ok) {
        setState(() => _error = _auth.errorMessage.isNotEmpty
            ? _auth.errorMessage
            : 'تعذّر إرسال الرمز، حاول لاحقاً');
        return;
      }

      // Restart cooldown after a successful resend
      _startCooldown(120);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // --- main verify logic ---
  Future<void> _verify() async {
    final code = _collect();
    if (code.length < _len) {
      setState(() => _error = 'الرمز غير مكتمل');
      return;
    }
    if (_phone.isEmpty) {
      setState(() => _error = 'رقم الهاتف غير معروف لهذه الصفحة');
      return;
    }

    // ✅ Password reset flow → verify with server first, then navigate only if OK
    if (_flow == 'reset') {
      try {
        setState(() {
          _isVerifying = true;
          _error = null;
        });

        final ok = await _auth.verifyOtpForReset(
          phoneNumber: _phone,
          otp: code,
        );

        if (ok) {
          // Only navigate if server says OTP is valid (but NOT consumed)
          Get.toNamed(
            Routes.resetPassword,
            arguments: {'phone': _phone, 'otp': code},
          );
        } else {
          setState(() => _error = _auth.errorMessage.isNotEmpty
              ? _auth.errorMessage
              : 'رمز التحقق غير صحيح');
        }
      } finally {
        if (mounted) setState(() => _isVerifying = false);
      }
      return;
    }

    // 🧭 Explicit registration flow (with registration token)
    if (_flow == 'register') {
      try {
        setState(() {
          _isVerifying = true;
          _error = null;
        });

        final ok = await _auth.verifyOtpForRegistration(
          phoneNumber: _phone,
          otp: code,
        );
        if (!ok) {
          setState(() => _error = _auth.errorMessage.isNotEmpty
              ? _auth.errorMessage
              : 'رمز التحقق غير صحيح');
          return;
        }

        final args = (Get.arguments as Map?) ?? {};
        final created = await _auth.registerAfterOtp(
          firstName: (args['firstName'] ?? '').toString(),
          lastName: (args['lastName'] ?? '').toString(),
          password: (args['password'] ?? '').toString(),
          phoneNumber: _phone,
          branchId: (args['branchId'] ?? '').toString(),
        );

        if (created) {
          Get.offAllNamed(Routes.main);
        }
      } finally {
        if (mounted) setState(() => _isVerifying = false);
      }
      return;
    }

    // 🔁 Default 'verify' flow (post-registration verification)
    try {
      setState(() {
        _isVerifying = true;
        _error = null;
      });

      final res = await _auth.verifyPhoneWithOtp(
        phoneNumber: _phone,
        otp: code,
      );

      if (res) {
        // Navigation handled by calling page usually; safe fallback to main
        Get.offAllNamed(Routes.main);
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _AnimatedLogo(),
                const SizedBox(height: 32),
                Text(
                  _flow == 'reset' ? 'تحقق من رقمك' : 'رمز التحقق',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                Text('أدخل الرمز المرسل إلى', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                if (_phone.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      _phone,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),

                _OtpBoxes(length: _len, tcs: _tcs, fns: _fns, filled: _filled, onChanged: _onChanged),

                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: (_error != null && _error!.isNotEmpty) ? 30 : 0,
                  child: (_error != null && _error!.isNotEmpty)
                      ? Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 14, fontWeight: FontWeight.w500))
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: _ActionButton(icon: Icons.content_paste, label: 'لصق', onTap: _paste)),
                      const SizedBox(width: 16),
                      Flexible(child: _ActionButton(icon: Icons.clear, label: 'مسح', onTap: _clearAll)),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // --- Resend OTP section with cooldown ---
                Builder(
                  builder: (_) {
                    final canResend = _cooldown == 0 && !_isVerifying;
                    final label = canResend
                        ? 'إعادة إرسال الرمز'
                        : 'يمكنك الإعادة خلال ${(_cooldown ~/ 60).toString().padLeft(2, '0')}:${(_cooldown % 60).toString().padLeft(2, '0')}';

                    return InkWell(
                      onTap: canResend ? _resend : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: canResend ? AppColors.primaryLight : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 18, color: canResend ? AppColors.primary : AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: canResend ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                ShamraButton(
                  text: 'تأكيد',
                  onPressed: _isVerifying ? null : _verify,
                  isLoading: _isVerifying,
                  icon: Icons.verified_user,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= Helper Widgets =======================

class _OtpBoxes extends StatelessWidget {
  final int length;
  final List<TextEditingController> tcs;
  final List<FocusNode> fns;
  final List<bool> filled;
  final void Function(int idx, String v) onChanged;

  const _OtpBoxes({
    required this.length,
    required this.tcs,
    required this.fns,
    required this.filled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.ltr,
          children: List.generate(length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: tcs[i],
                  focusNode: fns[i],
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: filled[i] ? AppColors.primary : AppColors.textPrimary,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  onChanged: (v) => onChanged(i, v),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: filled[i] ? AppColors.primaryLight : AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: filled[i] ? AppColors.primary : AppColors.outline,
                        width: filled[i] ? 2 : 1.5,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(color: AppColors.primary, width: 2.5),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  @override
  __AnimatedLogoState createState() => __AnimatedLogoState();
}

class __AnimatedLogoState extends State<_AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.rotate(
        angle: _rotateAnimation.value,
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Icon(Icons.lock_outline, size: 45, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
