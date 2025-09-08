import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/branch_controller.dart';
import '../../../data/models/branch.dart';
import '../../widgets/common_widgets.dart';

class BranchSelectionPage extends StatelessWidget {
  const BranchSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<BranchController>(
        init: BranchController(),
        builder: (controller) => Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Simplified Header
                _buildHeader(controller),

                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshBranches,
                    color: AppColors.primary,
                    child: Obx(() {
                      if (controller.isLoading) {
                        return _buildLoadingState();
                      }

                      if (controller.errorMessage.isNotEmpty) {
                        return _buildErrorState(controller);
                      }

                      if (controller.branches.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildSimplifiedBranchList(controller);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BranchController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Top Row with Logo and Logout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Title
              Row(
                children: [
                  const ShamraLogo(size: 50, showShadow: false),
                  const SizedBox(width: 12),
                  const Text(
                    'شمرا',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              // Logout Button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _showLogoutDialog(controller),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                  tooltip: 'تسجيل الخروج',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Welcome Message
          const Text(
            'اختر الفرع لرؤية منتجاته',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedBranchList(BranchController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Count
          Text(
            'الفروع المتاحة (${controller.branches.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          // Branch Grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 16,
                childAspectRatio: 3.2,
              ),
              itemCount: controller.branches.length,
              itemBuilder: (context, index) {
                final branch = controller.branches[index];
                return _buildSimpleBranchCard(branch, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBranchCard(Branch branch, BranchController controller) {
    return Obx(() {
      final isSelected = controller.selectedBranch?.id == branch.id;
      final isSelecting = controller.isSelecting && isSelected;

      return ShamraCard(
        onTap: isSelecting ? null : () => controller.selectBranch(branch),
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            // Branch Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: branch.isMainBranch
                      ? AppColors.secondaryGradient
                      : AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                branch.isMainBranch
                    ? Icons.business_rounded
                    : Icons.store_rounded,
                color: AppColors.white,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            // Branch Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Name with Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          branch.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (branch.isMainBranch)
                        ShamraChip(
                          label: 'رئيسي',
                          isSelected: true,
                          isSecondary: true,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          branch.fullAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Phone (if available)
                  if (branch.phone?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          branch.phone!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Selection Indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelecting
                  ? const LoadingWidget(size: 20)
                  : Icon(
                      isSelected
                          ? Icons.check_rounded
                          : Icons.arrow_back_ios_rounded,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                      size: 20,
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loading title
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 16),

            // Loading cards
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BranchController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              'لا يمكن تحميل الفروع الآن',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ShamraButton(
              text: 'إعادة المحاولة',
              onPressed: controller.refreshBranches,
              icon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.store_outlined,
                size: 40,
                color: AppColors.grey,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'لا توجد فروع',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Text(
              'لا توجد فروع متاحة حالياً',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BranchController controller) {
    Get.dialog(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من تسجيل الخروج؟',
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
                controller.logout();
              },
              width: 120,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }
}
