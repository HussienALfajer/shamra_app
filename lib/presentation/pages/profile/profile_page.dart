import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/common_widgets.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: GetBuilder<AuthController>(
          builder: (authController) {
            if (!authController.isLoggedIn) {
              return _buildLoginRequired();
            }

            return _buildProfileContent(authController);
          },
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.person_outline,
                size: 60,
                color: AppColors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'تسجيل دخول مطلوب',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'يرجى تسجيل الدخول لإدارة حسابك',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ShamraButton(
                    text: 'تسجيل دخول',
                    onPressed: () => Get.toNamed('/login'),
                    icon: Icons.login_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShamraButton(
                    text: 'إنشاء حساب',
                    onPressed: () => Get.toNamed('/register'),
                    icon: Icons.person_add_rounded,
                    isSecondary: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(AuthController authController) {
    final user = authController.currentUser!;

    return CustomScrollView(
      slivers: [
        // Profile Header
        SliverAppBar(
          expandedHeight: 280,
          backgroundColor: AppColors.primary,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _buildProfileHeader(user),
            ),
          ),
          title: const Text(
            'حسابي',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Account Statistics
                _buildAccountStats(),

                const SizedBox(height: 24),

                // Account Settings
                _buildAccountSettings(authController),

                const SizedBox(height: 24),

                // App Settings
                _buildAppSettings(),

                const SizedBox(height: 24),

                // About Section
                _buildAboutSection(),

                const SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(authController),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: AppColors.white, width: 3),
            ),
            child: Center(
              child: Text(
                user.firstName.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // User Name
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // User Email
          Text(
            user.email,
            style: const TextStyle(fontSize: 16, color: AppColors.white),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Edit Profile Button
          ShamraButton(
            text: 'تعديل الملف الشخصي',
            onPressed: () => Get.toNamed('/edit-profile'),
            isOutlined: true,
            height: 40,
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStats() {
    return GetBuilder<OrderController>(
      builder: (orderController) {
        final summary = orderController.orderSummary;

        return ShamraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إحصائيات الحساب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'إجمالي الطلبات',
                      summary['totalOrders'].toString(),
                      Icons.receipt_long_rounded,
                      AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'إجمالي المبلغ',
                      '${summary['totalAmount'].toStringAsFixed(0)} ر.س',
                      Icons.payments_rounded,
                      AppColors.secondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'طلبات مكتملة',
                      summary['deliveredCount'].toString(),
                      Icons.check_circle_rounded,
                      AppColors.success,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'قيد التنفيذ',
                      summary['pendingCount'].toString(),
                      Icons.pending_rounded,
                      AppColors.warning,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(AuthController authController) {
    return ShamraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات الحساب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          _buildSettingItem(
            'تعديل الملف الشخصي',
            'تعديل المعلومات الشخصية',
            Icons.person_outline,
            () => Get.toNamed('/edit-profile'),
          ),

          _buildSettingItem(
            'تغيير كلمة المرور',
            'تحديث كلمة المرور الخاصة بك',
            Icons.lock_outline,
            () => Get.toNamed('/change-password'),
          ),

          _buildSettingItem(
            'العناوين',
            'إدارة عناوين التوصيل',
            Icons.location_on_outlined,
            () => Get.toNamed('/addresses'),
          ),

          _buildSettingItem(
            'طرق الدفع',
            'إدارة طرق الدفع المحفوظة',
            Icons.payment_outlined,
            () => Get.toNamed('/payment-methods'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return ShamraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إعدادات التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          _buildSettingItem(
            'الإشعارات',
            'إدارة إشعارات التطبيق',
            Icons.notifications_outlined,
            () => Get.toNamed('/notification-settings'),
          ),

          _buildSettingItem(
            'اللغة',
            'تغيير لغة التطبيق',
            Icons.language_outlined,
            () => _showLanguageDialog(),
          ),

          _buildSettingItem(
            'المظهر',
            'المظهر الفاتح أو الداكن',
            Icons.palette_outlined,
            () => _showThemeDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return ShamraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حول التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          _buildSettingItem(
            'مركز المساعدة',
            'الأسئلة الشائعة والدعم',
            Icons.help_outline,
            () => Get.toNamed('/help'),
          ),

          _buildSettingItem(
            'اتصل بنا',
            'تواصل مع فريق الدعم',
            Icons.contact_support_outlined,
            () => Get.toNamed('/contact'),
          ),

          _buildSettingItem(
            'سياسة الخصوصية',
            'اطلع على سياسة الخصوصية',
            Icons.privacy_tip_outlined,
            () => Get.toNamed('/privacy-policy'),
          ),

          _buildSettingItem(
            'شروط الاستخدام',
            'اطلع على شروط الاستخدام',
            Icons.description_outlined,
            () => Get.toNamed('/terms'),
          ),

          _buildSettingItem(
            'إصدار التطبيق',
            'الإصدار 1.0.0',
            Icons.info_outline,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            if (onTap != null)
              const Icon(
                Icons.arrow_back_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return ShamraButton(
      text: 'تسجيل خروج',
      onPressed: () => _showLogoutDialog(authController),
      icon: Icons.logout_rounded,
      width: double.infinity,
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج من حسابك؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ShamraButton(
            text: 'تسجيل الخروج',
            onPressed: () {
              Get.back();
              authController.logout();
            },
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'اختر اللغة',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('العربية', true),
            _buildLanguageOption('English', false),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return InkWell(
      onTap: () => Get.back(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
            const SizedBox(width: 16),
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'اختر المظهر',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('المظهر الفاتح', Icons.light_mode, true),
            _buildThemeOption('المظهر الداكن', Icons.dark_mode, false),
            _buildThemeOption('تلقائي', Icons.auto_mode, false),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => Get.back(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.grey,
            ),
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(
              theme,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
