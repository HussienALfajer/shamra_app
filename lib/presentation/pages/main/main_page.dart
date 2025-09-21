import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/app_routes.dart';
import '../../../data/utils/helpers.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/category_controller.dart';
import '../../widgets/product_card.dart';
import '../../widgets/common_widgets.dart';
import '../cart/cart_page.dart';
import '../order/order_page.dart';
import '../product/product_page.dart';
import '../profile/profile_page.dart';
import '../favorite/favorites_page.dart';

/// الصفحة الرئيسية للتنقل بين الأقسام (الرئيسية - المنتجات - السلة - الطلبات - الحساب)
/// تستخدم IndexedStack للحفاظ على حالة كل صفحة
/// تدعم النظام التفاعلي مع عداد المنتجات في السلة
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mainController = Get.find<MainController>();
    final cartController = Get.find<CartController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        /// محتوى الصفحات بناءً على التبويب المحدد
        body: Obx(() {
          return IndexedStack(
            index: mainController.currentIndex.value,
            children: const [
              CustomerHomePage(),
              ProductsPage(),
              CartPage(),
              OrdersPage(),
              ProfilePage(),
            ],
          );
        }),

        /// شريط التنقل السفلي المحسّن مع أنيميشن
        bottomNavigationBar: Obx(() {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'الرئيسية',
                      currentIndex: mainController.currentIndex.value,
                      onTap: () => mainController.changeTab(0),
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Icons.grid_view_outlined,
                      activeIcon: Icons.grid_view_rounded,
                      label: 'المنتجات',
                      currentIndex: mainController.currentIndex.value,
                      onTap: () => mainController.changeTab(1),
                    ),
                    _buildNavItemWithBadge(
                      index: 2,
                      icon: Icons.shopping_cart_outlined,
                      activeIcon: Icons.shopping_cart_rounded,
                      label: 'السلة',
                      currentIndex: mainController.currentIndex.value,
                      badgeCount: cartController.itemCount,
                      onTap: () => mainController.changeTab(2),
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long_rounded,
                      label: 'الطلبات',
                      currentIndex: mainController.currentIndex.value,
                      onTap: () => mainController.changeTab(3),
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: 'الحساب',
                      currentIndex: mainController.currentIndex.value,
                      onTap: () => mainController.changeTab(4),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// بناء عنصر التنقل العادي مع أنيميشن سلس
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// حاوي الأيقونة مع أنيميشن
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.primary : AppColors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              /// النص مع أنيميشن
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.grey,
                  height: 1.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء عنصر التنقل مع Badge (للسلة) مع أنيميشن متقدم
  Widget _buildNavItemWithBadge({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
    required int badgeCount,
    required VoidCallback onTap,
  }) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// حاوي الأيقونة مع Badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      color: isActive ? AppColors.primary : AppColors.grey,
                      size: 24,
                    ),
                  ),
                  /// Badge مع أنيميشن متطور
                  if (badgeCount > 0)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        scale: 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              /// النص مع أنيميشن
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.grey,
                  height: 1.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// الصفحة الرئيسية للمستخدم (Home داخل MainPage)
/// تعرض البحث، الفئات، والمنتجات المختلفة
class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            /// شريط التطبيق العلوي مع الشعار والإجراءات
            _buildSliverAppBar(),

            /// شريط البحث المحسّن
            SliverToBoxAdapter(
              child: _buildSearchSection(controller),
            ),

            /// نتائج البحث (إذا وجدت)
            Obx(() {
              if (controller.searchQuery.isNotEmpty) {
                return _buildSearchResults(controller);
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }),

            /// الفئات الرئيسية
            SliverToBoxAdapter(
              child: GetBuilder<CategoryController>(
                init: CategoryController(),
                builder: (categoryController) => Obx(() {
                  if (categoryController.isLoading) {
                    return _buildCategoriesShimmer();
                  }

                  if (categoryController.categories.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.category_outlined,
                      title: 'لا توجد فئات',
                      message: 'لم يتم العثور على أي فئات',
                    );
                  }

                  return _buildCategoriesSection(categoryController.categories);
                }),
              ),
            ),

            /// المنتجات المميزة
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading) {
                  return _buildProductsShimmer();
                }
                return _buildProductSection(
                  title: 'المنتجات المميزة',
                  icon: Icons.star_rounded,
                  products: controller.featuredProducts,
                  onSeeAll: () => _navigateToProducts(1), // تبويبة المميزة
                );
              }),
            ),

            /// العروض الخاصة
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading) {
                  return _buildProductsShimmer();
                }
                return _buildProductSection(
                  title: 'عروض خاصة',
                  icon: Icons.local_offer_rounded,
                  products: controller.onSaleProducts,
                  onSeeAll: () => _navigateToProducts(2), // تبويبة العروض
                );
              }),
            ),

            /// أحدث المنتجات
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading) {
                  return _buildProductsShimmer();
                }
                return _buildProductSection(
                  title: 'أحدث المنتجات',
                  icon: Icons.new_releases_rounded,
                  products: controller.recentProducts,
                  onSeeAll: () => _navigateToProducts(0), // تبويبة الكل
                );
              }),
            ),

            /// مساحة سفلية للتنقل
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  /// دالة التنقل إلى صفحة المنتجات مع التبويبة المحددة - محدثة
  void _navigateToProducts(int initialTab) {
    // تغيير التبويب في MainController إلى صفحة المنتجات
    final mainController = Get.find<MainController>();
    mainController.changeTab(1);

    // إرسال التبويبة المطلوبة للـ ProductsTabController مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final tabController = Get.find<ProductsTabController>();
        tabController.changeTab(initialTab);
      } catch (e) {
        // إذا لم يكن الـ controller موجود، قم بإنشاؤه وتعيين التبويبة
        Get.put(ProductsTabController());
        final tabController = Get.find<ProductsTabController>();
        tabController.changeTab(initialTab);
      }
    });
  }

  /// بناء شريط التطبيق العلوي
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.white,
      elevation: 1,
      title: Row(
        children: [
          Image.asset(
            AppConstants.logoPath,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          const Text(
            'Shamra',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.textPrimary),
          onPressed: () => Get.toNamed(Routes.favorites),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
          onPressed: () => Get.toNamed(Routes.notifications),
        ),
      ],
    );
  }

  /// بناء قسم البحث المحسّن
  Widget _buildSearchSection(MainController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ShamraTextField(
        hintText: 'ابحث عن المنتجات...',
        icon: Icons.search,
        controller: controller.searchController,
        suffixIcon: Obx(() {
          return controller.searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: AppColors.grey),
            onPressed: controller.clearSearch,
          )
              : const SizedBox.shrink();
        }),
        onChanged: (value) {
          if (value.trim().isNotEmpty) {
            controller.searchProducts(value.trim());
          } else {
            controller.clearSearch();
          }
        },
      ),
    );
  }

  /// بناء نتائج البحث
  Widget _buildSearchResults(MainController controller) {
    if (controller.isSearching) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 100,
          child: const Center(
            child: LoadingWidget(message: "جاري البحث..."),
          ),
        ),
      );
    }

    if (controller.searchResults.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'نتائج البحث عن "${controller.searchQuery}"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  ShamraChip(
                    label: '${controller.searchResults.length} منتج',
                    isSelected: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final product = controller.searchResults[index];
                    return SizedBox(
                      width: 170,
                      child: ProductCard(
                        product: product,
                        onTap: () => Get.toNamed(
                          Routes.productDetails,
                          arguments: product,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const ShamraDivider(),
            ],
          ),
        ),
      );
    } else {
      return SliverToBoxAdapter(
        child: ShamraCard(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد نتائج للبحث عن "${controller.searchQuery}"',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'جرب كلمات مختلفة أو تحقق من الإملاء',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  /// بناء قسم الفئات الرئيسية
  Widget _buildCategoriesSection(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الفئات الرئيسية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(Routes.categories),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        /// قائمة الفئات (أفقية)
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () => Get.toNamed(
                  Routes.categoryDetails,
                  arguments: {
                    'categoryId': category.id,
                    'categoryName': category.displayName,
                  },
                ),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(left: 12),
                  child: Column(
                    children: [
                      /// صورة الفئة
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: AppColors.primaryGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: category.image != null && category.image!.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: HelperMethod.getImageUrl(category.image!),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: AppColors.grey),
                          )
                              : const Icon(
                            Icons.category,
                            color: AppColors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      /// اسم الفئة
                      Text(
                        category.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// بناء قسم المنتجات مع زر عرض الكل
  Widget _buildProductSection({
    required String title,
    required IconData icon,
    required List<Product> products,
    required VoidCallback onSeeAll,
  }) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
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
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemExtent: 182,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Align(
                  alignment: Alignment.centerLeft,
                  child: ProductCard(
                    product: product,
                    width: 170,
                    isGridView: false,
                    onTap: () => Get.toNamed(
                      Routes.productDetails,
                      arguments: product,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// مؤثر التحميل للفئات (Shimmer)
  Widget _buildCategoriesShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 6,
          itemBuilder: (context, index) => Container(
            width: 80,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  /// مؤثر التحميل للمنتجات (Shimmer)
  Widget _buildProductsShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, index) => Container(
            width: 170,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}