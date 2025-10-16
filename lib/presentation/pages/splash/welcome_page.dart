// lib/presentation/pages/splash/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/common_widgets.dart';

/// Welcome screen with app introduction and navigation to auth pages.
/// Displayed when user is not logged in.
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToRegister() => Get.offAllNamed(Routes.register);
  void _goToLogin() => Get.offAllNamed(Routes.login);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final w = MediaQuery.of(context).size.width;
              return Stack(
                children: [
                  // App logo
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.22 +
                        _slideAnimation.value,
                    left: w * 0.5 - 73,
                    child: Image.asset(
                      AppConstants.logoPath,
                      fit: BoxFit.contain,
                      width: 150,
                      height: 150,
                    ),
                  ),

                  // App title
                  Positioned(
                    top: 390 + _slideAnimation.value,
                    left: w * 0.5 - 100,
                    child: const SizedBox(
                      width: 200,
                      child: Text(
                        'شمرا',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w700,
                          fontSize: 52,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Tagline
                  Positioned(
                    top: 469 + _slideAnimation.value,
                    left: w * 0.5 - 132.5,
                    child: const SizedBox(
                      width: 265,
                      child: Text(
                        'تطبيق شمرا، دليلك الذكي لإدارة أعمالك بسهولة وسرعة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          height: 1.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  // Primary button - Register
                  Positioned(
                    top: 634,
                    left: w * 0.5 - 167.5,
                    child: ShamraButton(
                      text: "لنبدأ رحلتك الآن",
                      onPressed: _goToRegister,
                      width: 335,
                      height: 61,
                    ),
                  ),

                  // Secondary action - Login
                  Positioned(
                    top: 713,
                    right: 80,
                    left: w * 0.5 - 120,
                    child: GestureDetector(
                      onTap: _goToLogin,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "لدي حساب بالفعل",
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              height: 1.9,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppColors.white,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Bottom indicator
                  Positioned(
                    bottom: 14,
                    left: w * 0.5 - 67,
                    child: Container(
                      width: 134,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(34),
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
}