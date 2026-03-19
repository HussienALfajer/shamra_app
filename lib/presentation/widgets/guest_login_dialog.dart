import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/colors.dart';
import '../../routes/app_routes.dart';
import 'common_widgets.dart';

class GuestLoginDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onLoginSuccess;

  const GuestLoginDialog({
    super.key,
    required this.title,
    required this.message,
    this.onLoginSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_person_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ShamraButton(
              text: "تسجيل الدخول",
              width: double.infinity,
              onPressed: () {
                Get.back(); // Close dialog
                // Pass a flag to login page to indicate it was from a protected route
                Get.toNamed(Routes.login, arguments: {
                  'navigateOnSuccess': false,
                  'onLoginSuccess': onLoginSuccess,
                });
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.toNamed(Routes.register, arguments: {
                  'navigateOnSuccess': false,
                });
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "إنشاء حساب جديد",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "إلغاء",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper to show this dialog easily from anywhere.
  static void show({
    required String title,
    required String message,
    VoidCallback? onLoginSuccess,
  }) {
    Get.dialog(
      GuestLoginDialog(
        title: title,
        message: message,
        onLoginSuccess: onLoginSuccess,
      ),
      barrierDismissible: true,
    );
  }
}
