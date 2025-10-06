import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/main_controller.dart';
import '../../widgets/common_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'مرحباً بك في شمرا',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يرجى تسجيل الدخول للوصول إلى حسابك',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
  }

  Widget _buildProfileContent(AuthController authController) {
    // 🎯 احذف المتغير المحلي
    // final user = authController.currentUser; ❌

    if (authController.currentUser == null) {
      return _buildLoginRequired();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await authController.getProfile();
        await authController.getMerchantRequest();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Obx(() {
          // 🎯 استخدم authController.currentUser مباشرة
          final user = authController.currentUser;
          if (user == null) return const SizedBox();

          return Column(
            children: [
              const SizedBox(height: 40),
              _buildUserInfo(user, authController),
              const SizedBox(height: 24),
              _buildPointsCard(user), // 🎯 الآن سيتحدث
              const SizedBox(height: 24),
              _buildBranchInfo(authController),
              const SizedBox(height: 24),
              _buildMerchantRequest(authController),
              const SizedBox(height: 24),
              _buildActions(authController),
              const SizedBox(height: 40),
            ],
          );
        }),
      ),
    );
  }
  Widget _buildPointsCard(dynamic user) {
    return ShamraCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'نقاط المكافآت',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // النقاط المتاحة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'النقاط المتاحة',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${user.points}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'نقطة',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // إحصائيات النقاط
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user.totalPointsEarned}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'مكتسبة',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.redeem_rounded,
                        color: AppColors.warning,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${user.totalPointsUsed}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'مستخدمة',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(dynamic user, AuthController authController) {
    return ShamraCard(
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                user.firstName.substring(0,1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Details
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (user.phoneNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              user.phoneNumber!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Edit Profile Button
          ShamraButton(
            text: 'تعديل الملف الشخصي',
            onPressed: () => Get.toNamed('/edit-profile'),
            icon: Icons.edit_outlined,
            isOutlined: true,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildBranchInfo(AuthController authController) {
    final user = authController.currentUser!;

    return ShamraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'الفرع المحدد',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.selectedBranchObject?.name ?? 'لم يتم اختيار فرع',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (user.selectedBranchObject?.address != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.selectedBranchObject!.address!.street,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await Get.toNamed(Routes.branchSelection);
                    // ✅ بعد الرجوع من اختيار الفرع: حدّث المستخدم محلياً لتنعكس التغييرات فوراً
                    final auth = Get.find<AuthController>();
                    await auth.reloadFromStorage();

                    // (اختياري) إن رغبت بتطبيق توكن الفرع من المحلي مباشرة:
                    // final bid = StorageService.getBranchId();
                    // if (bid != null) await auth.applyBranchAuthFromLocal(bid);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantRequest(AuthController authController) {
    final merchantRequest = authController.merchantRequest;

    return ShamraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'طلب التاجر',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (merchantRequest != null)
            _buildMerchantStatus(merchantRequest, authController)
          else
            _buildMerchantRequestButton(authController),
        ],
      ),
    );
  }

  Widget _buildMerchantStatus(
      Map<String, dynamic> request,
      AuthController authController,
      ) {
    Color _getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return AppColors.warning;
        case 'approved':
          return AppColors.success;
        case 'rejected':
          return AppColors.error;
        default:
          return AppColors.grey;
      }
    }

    IconData _getStatusIcon(String status) {
      switch (status) {
        case 'pending':
          return Icons.pending_rounded;
        case 'approved':
          return Icons.check_circle_rounded;
        case 'rejected':
          return Icons.cancel_rounded;
        default:
          return Icons.help_rounded;
      }
    }

    String _getStatusText(String status) {
      switch (status) {
        case 'pending':
          return 'قيد المراجعة';
        case 'approved':
          return 'تم القبول';
        case 'rejected':
          return 'تم الرفض';
        default:
          return 'حالة غير معروفة';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(request['status']).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(request['status']).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(request['status']),
                color: _getStatusColor(request['status']),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(request['status']),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(request['status']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'اسم المتجر: ${request['storeName']}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'العنوان: ${request['address']}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (request['status'] == 'rejected' &&
              request['rejectionReason'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'سبب الرفض: ${request['rejectionReason']}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ShamraButton(
              text: 'إعادة التقديم',
              onPressed: () => _showMerchantRequestDialog(authController),
              icon: Icons.refresh_rounded,
              isOutlined: true,
              width: double.infinity,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMerchantRequestButton(AuthController authController) {
    return ShamraButton(
      text: 'طلب أن تصبح تاجراً',
      onPressed: () => _showMerchantRequestDialog(authController),
      icon: Icons.store_rounded,
      width: double.infinity,
    );
  }

  Widget _buildActions(AuthController authController) {
    return Column(
      children: [
        ShamraButton(
          text: 'تغيير كلمة المرور',
          onPressed: () => Get.toNamed('/change-password'),
          icon: Icons.lock_outlined,
          isOutlined: true,
          width: double.infinity,
        ),
        const SizedBox(height: 16),
        ShamraButton(
          text: 'تسجيل الخروج',
          onPressed: () => _showLogoutDialog(authController),
          icon: Icons.logout_rounded,
          backgroundColor: AppColors.error,
          width: double.infinity,
        ),
      ],
    );
  }

  void _showMerchantRequestDialog(AuthController authController) {
    final storeNameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneNumberController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'طلب أن تصبح تاجراً',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: storeNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المتجر',
                  hintText: 'أدخل اسم متجرك',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                  hintText: 'أدخل عنوان متجرك',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: 'أدخل رقم هاتفك',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ShamraButton(
                text: 'إرسال الطلب',
                onPressed: () async {
                  if (storeNameController.text.isEmpty ||
                      addressController.text.isEmpty ||
                      phoneNumberController.text.isEmpty) {
                    ShamraSnackBar.show(
                      context: Get.context!,
                      message: 'يرجى ملء جميع الحقول المطلوبة',
                      type: SnackBarType.error,
                    );
                    return;
                  }
                  await authController.submitMerchantRequest(
                    storeName: storeNameController.text,
                    address: addressController.text,
                    phoneNumber: phoneNumberController.text,
                  );
                  Get.back();
                },
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
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
          'هل أنت متأكد أنك تريد تسجيل الخروج؟',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ShamraButton(
            text: 'تسجيل الخروج',
            onPressed: () async {
              Get.back();
              await authController.logout();
            },
            backgroundColor: AppColors.error,
          ),
        ],
      ),
    );
  }
}
