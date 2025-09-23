import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/order_controller.dart';
import '../../widgets/common_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _scrollController;
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  void _onScroll() {
    const double threshold = 100.0;
    final bool shouldCollapse = _scrollController.offset > threshold;
    if (shouldCollapse != _isHeaderCollapsed) {
      setState(() {
        _isHeaderCollapsed = shouldCollapse;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final main = Get.find<MainController>();

    return Directionality(
        textDirection: TextDirection.rtl,
        child: WillPopScope(
          onWillPop: () async {
            final handled = main.backToPreviousTab();
            return !handled;
          },
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
        ));
    }

  Widget _buildLoginRequired() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.primaryGradient
                              .map((c) => c.withOpacity(0.1))
                              .toList(),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(70),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'مرحباً بك في شمرا',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى تسجيل الدخول للوصول إلى حسابك\nوإدارة طلباتك وتفضيلاتك',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildAnimatedLoginButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLoginButtons() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                ShamraButton(
                  text: 'تسجيل دخول',
                  onPressed: () => Get.toNamed('/login'),
                  icon: Icons.login_rounded,
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                ShamraButton(
                  text: 'إنشاء حساب جديد',
                  onPressed: () => Get.toNamed('/register'),
                  icon: Icons.person_add_rounded,
                  isOutlined: true,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileContent(AuthController authController) {
    final user = authController.currentUser!;

    return RefreshIndicator(
      onRefresh: () async {
        await authController.getProfile();
        final orderController = Get.find<OrderController>();
        await orderController.refreshOrders();
      },
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAnimatedSliverAppBar(user),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildAccountStats(),
                    const SizedBox(height: 20),
                    _buildAccountSettings(authController),
                    const SizedBox(height: 20),
                    _buildAppSettings(),
                    const SizedBox(height: 20),
                    _buildAboutSection(),
                    const SizedBox(height: 20),
                    _buildLogoutButton(authController),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSliverAppBar(dynamic user) {
    return SliverAppBar(
      expandedHeight: 320,
      backgroundColor: AppColors.primary,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
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
        title: AnimatedOpacity(
          opacity: _isHeaderCollapsed ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            user.fullName,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit_rounded, color: AppColors.white),
          ),
          onPressed: () => Get.toNamed('/edit-profile'),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(color: AppColors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          user.firstName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.email,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        ],
      ),
    );
  }


  Widget _buildQuickActions() {
    return ShamraCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجراءات سريعة',
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
                child: _buildQuickActionItem(
                  'تعديل الملف',
                  Icons.edit_rounded,
                  AppColors.primary,
                      () => Get.toNamed('/edit-profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionItem(
                  'طلباتي',
                  Icons.receipt_long_rounded,
                  AppColors.secondary,
                      () => Get.toNamed('/orders'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionItem(
                  'العناوين',
                  Icons.location_on_rounded,
                  AppColors.success,
                      () => Get.toNamed('/addresses'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionItem(
                  'المساعدة',
                  Icons.help_rounded,
                  AppColors.info,
                      () => Get.toNamed('/help'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(String label,
      IconData icon,
      Color color,
      VoidCallback onTap,) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
              Row(
                children: [
                  const Icon(
                    Icons.analytics_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'إحصائيات الحساب',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/order-analytics'),
                    child: const Text(
                      'عرض التفاصيل', style: TextStyle(fontSize: 14),),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    'إجمالي الطلبات',
                    summary['totalOrders'].toString(),
                    Icons.receipt_long_rounded,
                    AppColors.primary,
                    '${((summary['totalOrders'] as int) * 100 / 50).clamp(
                        0, 100).toInt()}%',
                  ),
                  _buildStatCard(
                    'إجمالي المبلغ',
                    '${summary['totalAmount'].toStringAsFixed(0)} ر.س',
                    Icons.payments_rounded,
                    AppColors.secondary,
                    '+12%',
                  ),
                  _buildStatCard(
                    'طلبات مكتملة',
                    summary['deliveredCount'].toString(),
                    Icons.check_circle_rounded,
                    AppColors.success,
                    '${summary['totalOrders'] > 0
                        ? ((summary['deliveredCount'] as int) * 100 /
                        (summary['totalOrders'] as int)).toInt()
                        : 0}%',
                  ),
                  _buildStatCard(
                    'قيد التنفيذ',
                    summary['pendingCount'].toString(),
                    Icons.pending_rounded,
                    AppColors.warning,
                    summary['pendingCount'] > 0 ? 'نشط' : 'لا يوجد',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label,
      String value,
      IconData icon,
      Color color,
      String trend,) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(AuthController authController) {
    final settings = [
      {
        'title': 'تعديل الملف الشخصي',
        'subtitle': 'تعديل المعلومات الشخصية والصورة',
        'icon': Icons.person_outline_rounded,
        'route': '/edit-profile',
        'color': AppColors.primary,
      },
      {
        'title': 'تغيير كلمة المرور',
        'subtitle': 'تحديث كلمة المرور لحماية الحساب',
        'icon': Icons.lock_outline_rounded,
        'route': '/change-password',
        'color': AppColors.warning,
      },
      {
        'title': 'العناوين المحفوظة',
        'subtitle': 'إدارة عناوين التوصيل والفوترة',
        'icon': Icons.location_on_outlined,
        'route': '/addresses',
        'color': AppColors.success,
      },
      {
        'title': 'طرق الدفع',
        'subtitle': 'إدارة البطاقات والمحافظ الرقمية',
        'icon': Icons.payment_outlined,
        'route': '/payment-methods',
        'color': AppColors.info,
      },
    ];

    return _buildSettingsSection(
      'إعدادات الحساب',
      Icons.account_circle_rounded,
      settings,
    );
  }

  Widget _buildAppSettings() {
    final settings = [
      {
        'title': 'الإشعارات',
        'subtitle': 'إدارة تفضيلات الإشعارات',
        'icon': Icons.notifications_outlined,
        'action': () => Get.toNamed('/notification-settings'),
        'color': AppColors.primary,
      },
      {
        'title': 'اللغة والمنطقة',
        'subtitle': 'العربية - المملكة العربية السعودية',
        'icon': Icons.language_outlined,
        'action': () => _showLanguageDialog(),
        'color': AppColors.secondary,
      },
      {
        'title': 'المظهر',
        'subtitle': 'المظهر الفاتح',
        'icon': Icons.palette_outlined,
        'action': () => _showThemeDialog(),
        'color': AppColors.info,
      },
      {
        'title': 'إعدادات الخصوصية',
        'subtitle': 'التحكم في البيانات المشاركة',
        'icon': Icons.privacy_tip_outlined,
        'action': () => Get.toNamed('/privacy-settings'),
        'color': AppColors.warning,
      },
    ];

    return _buildSettingsSection(
      'إعدادات التطبيق',
      Icons.settings_rounded,
      settings,
    );
  }

  Widget _buildAboutSection() {
    final settings = [
      {
        'title': 'مركز المساعدة',
        'subtitle': 'الأسئلة الشائعة والدعم الفني',
        'icon': Icons.help_outline_rounded,
        'action': () => Get.toNamed('/help'),
        'color': AppColors.success,
      },
      {
        'title': 'اتصل بنا',
        'subtitle': 'تواصل مع فريق الدعم',
        'icon': Icons.contact_support_outlined,
        'action': () => Get.toNamed('/contact'),
        'color': AppColors.info,
      },
      {
        'title': 'قيم التطبيق',
        'subtitle': 'ساعدنا في تحسين الخدمة',
        'icon': Icons.star_outline_rounded,
        'action': () => _showRatingDialog(),
        'color': AppColors.secondary,
      },
      {
        'title': 'شارك التطبيق',
        'subtitle': 'أخبر أصدقائك عن شمرا',
        'icon': Icons.share_outlined,
        'action': () => _shareApp(),
        'color': AppColors.primary,
      },
      {
        'title': 'سياسة الخصوصية',
        'subtitle': 'اطلع على سياسة حماية البيانات',
        'icon': Icons.privacy_tip_outlined,
        'action': () => Get.toNamed('/privacy-policy'),
        'color': AppColors.warning,
      },
      {
        'title': 'شروط الاستخدام',
        'subtitle': 'الأحكام والشروط',
        'icon': Icons.description_outlined,
        'action': () => Get.toNamed('/terms'),
        'color': AppColors.darkGrey,
      },
      {
        'title': 'معلومات التطبيق',
        'subtitle': 'الإصدار 1.0.0 - أحدث إصدار',
        'icon': Icons.info_outline_rounded,
        'action': null,
        'color': AppColors.grey,
      },
    ];

    return _buildSettingsSection(
      'حول التطبيق',
      Icons.info_rounded,
      settings,
    );
  }

  Widget _buildSettingsSection(String title,
      IconData titleIcon,
      List<Map<String, dynamic>> items,) {
    return ShamraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) =>
              _buildSettingItem(
                item['title'] as String,
                item['subtitle'] as String,
                item['icon'] as IconData,
                item['action'] as VoidCallback?,
                item['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title,
      String subtitle,
      IconData icon,
      VoidCallback? onTap,
      Color color,) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
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
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error.withOpacity(0.8),
            AppColors.error,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(authController),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.white),
            SizedBox(width: 12),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Methods
  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج من حسابك؟ ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى حسابك.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.language_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text(
              'اختر اللغة',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('العربية', 'ar', true),
            const SizedBox(height: 8),
            _buildLanguageOption('English', 'en', false),
            const SizedBox(height: 8),
            _buildLanguageOption('Français', 'fr', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, String code, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Implement language change logic
          Get.back();
          Get.snackbar(
            'تم التغيير',
            'تم تغيير اللغة إلى $language',
            backgroundColor: AppColors.success,
            colorText: AppColors.white,
            snackPosition: SnackPosition.TOP,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColors.primary) : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons
                    .radio_button_off,
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
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.palette_rounded, color: AppColors.primary),
            SizedBox(width: 12),
            Text(
              'اختر المظهر',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('المظهر الفاتح', Icons.light_mode, true),
            const SizedBox(height: 8),
            _buildThemeOption('المظهر الداكن', Icons.dark_mode, false),
            const SizedBox(height: 8),
            _buildThemeOption('تلقائي', Icons.auto_mode, false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Implement theme change logic
          Get.back();
          Get.snackbar(
            'تم التغيير',
            'تم تغيير المظهر إلى $theme',
            backgroundColor: AppColors.success,
            colorText: AppColors.white,
            snackPosition: SnackPosition.TOP,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppColors.primary) : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons
                    .radio_button_off,
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
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    int rating = 0;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.star_rounded, color: AppColors.secondary),
            SizedBox(width: 12),
            Text(
              'قيم تطبيق شمرا',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'ما رأيك في تجربتك مع تطبيق شمرا؟',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => setState(() => rating = index + 1),
                      child: Icon(
                        rating > index ? Icons.star : Icons.star_border,
                        color: AppColors.secondary,
                        size: 32,
                      ),
                    );
                  }),
                ),
                if (rating > 0) ...[
                  const SizedBox(height: 16),
                  Text(
                    rating >= 4 ? 'شكراً لك! 🌟' : 'كيف يمكننا التحسين؟',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: rating > 0 ? () {
              Get.back();
              Get.snackbar(
                'شكراً لك',
                'تم إرسال تقييمك بنجاح',
                backgroundColor: AppColors.success,
                colorText: AppColors.white,
                snackPosition: SnackPosition.TOP,
              );
            } : null,
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    // TODO: Implement actual sharing functionality
    Get.snackbar(
      'مشاركة التطبيق',
      'تم نسخ رابط التطبيق إلى الحافظة',
      backgroundColor: AppColors.info,
      colorText: AppColors.white,
      snackPosition: SnackPosition.TOP,
      icon: const Icon(Icons.share, color: AppColors.white),
    );
  }
}