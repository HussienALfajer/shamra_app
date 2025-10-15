import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shamra_app/routes/app_routes.dart';
import '../../../core/constants/colors.dart';
import '../../widgets/common_widgets.dart';
import '../../controllers/auth_controller.dart';

class OtpPage extends StatefulWidget {
  final String? phone;
  final String flow; // 'verify' أو 'reset'
  const OtpPage({super.key, this.phone, this.flow = 'verify'});

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

  static const _len = 4; // طول الرمز
  late final List<TextEditingController> _tcs;
  late final List<FocusNode> _fns;
  late final List<bool> _filled;

  bool _isVerifying = false;
  String? _error;

  String get _phone {
    final p = widget.phone ?? '';
    final argsPhone = (Get.arguments is Map) ? (Get.arguments['phone']?.toString() ?? '') : '';
    return p.isNotEmpty ? p : argsPhone;
  }

  String get _flow {
    final f = widget.flow;
    final argsFlow = (Get.arguments is Map) ? (Get.arguments['flow']?.toString() ?? 'verify') : 'verify';
    return f.isNotEmpty ? f : argsFlow;
  }

  @override
  void initState() {
    super.initState();
    _tcs = List.generate(_len, (_) => TextEditingController());
    _fns = List.generate(_len, (_) => FocusNode());
    _filled = List.generate(_len, (_) => false);
  }

  @override
  void dispose() {
    for (final c in _tcs) c.dispose();
    for (final f in _fns) f.dispose();
    super.dispose();
  }

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
    for (final c in _tcs) c.clear();
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

    // ✅ مسار استرجاع كلمة السر: لا نتحقق هنا من السيرفر
    if (_flow == 'reset') {
      Get.toNamed(
        Routes.resetPassword,
        arguments: {'phone': _phone, 'otp': code},
      );
      return;
    }

    // ✅ مسار تفعيل الحساب بعد التسجيل: استخدم verify-otp
    try {
      setState(() {
        _isVerifying = true;
        _error = null;
      });

      final ok = await _auth.verifyPhoneWithOtp(
        phoneNumber: _phone,
        otp: code,
      );

      if (ok) {
        if (Get.previousRoute.isNotEmpty) {
          Get.back(result: true);
        } else {
          // Get.offAllNamed(Routes.branchSelection);
        }
      } else {
        setState(() => _error = _auth.errorMessage.isNotEmpty ? _auth.errorMessage : 'فشل التحقق');
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
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
            ),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _AnimatedLogo(),
                        const SizedBox(height: 32),
                        Text(
                          _flow == 'reset' ? 'تحقق من رقمك' : 'رمز التحقق',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('أدخل الرمز المرسل إلى',
                            style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        if (_phone.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
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

                        _OtpBoxes(
                          length: _len,
                          tcs: _tcs,
                          fns: _fns,
                          filled: _filled,
                          onChanged: _onChanged,
                        ),

                        const SizedBox(height: 16),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: (_error != null && _error!.isNotEmpty) ? 30 : 0,
                          child: (_error != null && _error!.isNotEmpty)
                              ? Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _ActionButton(
                                  icon: Icons.content_paste,
                                  label: 'لصق',
                                  onTap: _paste,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Flexible(
                                child: _ActionButton(
                                  icon: Icons.clear,
                                  label: 'مسح',
                                  onTap: _clearAll,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

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
                  inputFormatters:  [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  onChanged: (v) => onChanged(i, v),
                  onSubmitted: (_) {
                    if (i < length - 1) {
                      fns[i + 1].requestFocus();
                    }
                  },
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

    _rotateAnimation =
        Tween<double>(begin: -0.1, end: 0.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

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
      builder: (context, child) {
        return Transform.rotate(
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
                  ),
                ],
              ),
              child: const Icon(Icons.lock_outline, size: 45, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
