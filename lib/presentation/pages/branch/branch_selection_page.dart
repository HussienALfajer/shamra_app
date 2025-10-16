// lib/presentation/pages/branch/branch_selection_page.dart
import 'package:flutter/material.dart' hide ErrorWidget;
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/branch_controller.dart';
import '../../../data/models/branch.dart';
import '../../widgets/common_widgets.dart';

/// Branch Selection Page (UI only)
/// - Displays list of available branches
/// - Allows user to select a branch
/// - Uses BranchController for state management
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
            child: Stack(
              children: [
                // Branch list (below header)
                Positioned.fill(
                  top: 223,
                  child: RefreshIndicator(
                    onRefresh: controller.refreshBranches,
                    color: AppColors.primary,
                    child: Obx(() {
                      if (controller.isLoading) {
                        return _buildLoadingState();
                      }

                      if (controller.errorMessage.isNotEmpty) {
                        return ErrorWidget(
                          message: controller.errorMessage,
                          onRetry: controller.refreshBranches,
                        );
                      }

                      if (controller.branches.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildBranchList(controller);
                    }),
                  ),
                ),

                // Header
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildHeader(controller),
                ),

                // Background decoration
                _buildBackgroundDecor(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header component (logo + welcome text + logout button)
  Widget _buildHeader(BranchController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF034D97), Color(0xFF2E5BBA)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Top row (logo + name + logout button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        "assets/images/shamra_logo.png",
                        width: 60,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'شمرا',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              // Logout button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => controller.logout(),
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

          // Welcome text
          const Text(
            'مرحباً بك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'اختر الفرع المناسب حسب مدينتك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'لعرض المنتجات والخدمات المتاحة',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Branch list component
  Widget _buildBranchList(BranchController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // List title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'الفروع المتاحة (${controller.branches.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A90E2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Branch grid
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
                return _buildBranchCard(branch, controller);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Individual branch card
  Widget _buildBranchCard(Branch branch, BranchController controller) {
    return Obx(() {
      final isSelected = controller.selectedBranch?.id == branch.id;
      final isSelecting = controller.isSelecting && isSelected;

      return ShamraCard(
        onTap: isSelecting ? null : () => controller.selectBranch(branch),
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            const SizedBox(width: 16),

            // Branch details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch name + main badge
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
                        const ShamraChip(
                          label: 'رئيسي',
                          isSelected: true,
                          isSecondary: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Address
                  Row(
                    children: [
                      const Icon(
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

                  // Phone (optional)
                  if (branch.phone?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
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

            // Selection icon
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

  /// Loading state (Shimmer effect)
  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
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

  /// Empty state
  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      icon: Icons.store_outlined,
      title: 'لا توجد فروع',
      message: 'لا توجد فروع متاحة حالياً',
    );
  }

  /// Background decoration circles
  Widget _buildBackgroundDecor() {
    return Stack(
      children: [
        Positioned(top: -50, right: -50, child: _circle(150, 0.1)),
        Positioned(top: 50, left: -30, child: _circle(100, 0.4)),
        Positioned(top: 100, right: 50, child: _circle(80, 0.2)),
        Positioned(top: 190, left: 50, child: _circle(80, 0.2)),
      ],
    );
  }

  /// Circle decoration component
  Widget _circle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}