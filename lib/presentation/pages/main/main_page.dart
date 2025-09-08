import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shamra_app/presentation/pages/cart/cart_page.dart';
import 'package:shamra_app/presentation/pages/order/order_page.dart';
import 'package:shamra_app/presentation/pages/product/product_page.dart';
import 'package:shamra_app/presentation/pages/profile/profile_page.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';
import '../../../data/models/sub_category.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            CustomerHomePage(),
            ProductsPage(),
            CartPage(),
            OrdersPage(),
            ProfilePage(),
          ],
        ),
        bottomNavigationBar: Obx(() {
          final cartController = Get.find<CartController>();

          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            elevation: 8,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'المنتجات',
              ),
              BottomNavigationBarItem(
                icon: _buildCartIcon(cartController),
                activeIcon: _buildCartIcon(cartController, isActive: true),
                label: 'السلة',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'الطلبات',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'الحساب',
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCartIcon(
    CartController cartController, {
    bool isActive = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined),
        if (cartController.itemCount > 0)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                cartController.itemCount > 99
                    ? '99+'
                    : cartController.itemCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// Enhanced Customer Home Page
class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      init: MainController(),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              // Enhanced App Bar
              _buildShamraAppBar(),

              // Welcome Section
              _buildWelcomeSection(),

              // Search Bar
              _buildSearchSection(controller),

              // Main Content
              if (controller.isLoading)
                SliverToBoxAdapter(child: _buildLoadingShimmer())
              else ...[
                // Categories Section
                _buildCategoriesSection(),

                // Featured Products
                _buildFeaturedProductsSection(controller),

                // Sub-Categories Showcase
                _buildSubCategoriesSection(),

                // On Sale Products
                _buildOnSaleProductsSection(controller),

                // Recent Products
                _buildRecentProductsSection(controller),

                // Bottom Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShamraAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          const ShamraLogo(size: 36, showShadow: false),
          const SizedBox(width: 12),
          const Text(
            'شمرا',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.white),
          onPressed: () => Get.toNamed('/search'),
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.white,
          ),
          onPressed: () => Get.toNamed('/notifications'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحباً بك في شمرا',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اكتشف أفضل الأجهزة الإلكترونية بأسعار مميزة',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(MainController controller) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ShamraCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller.searchController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'ابحث عن المنتجات...',
              hintStyle: TextStyle(color: AppColors.textLight),
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onSubmitted: controller.searchProducts,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: GetBuilder<CategoryController>(
        init: CategoryController(),
        builder: (categoryController) => Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
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
                      onPressed: () => Get.toNamed('/categories'),
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (categoryController.isLoading) {
                  return _buildCategoriesShimmer();
                }

                if (categoryController.categories.isEmpty) {
                  return const SizedBox(
                    height: 120,
                    child: Center(
                      child: Text(
                        'لا توجد فئات متاحة',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categoryController.categories.take(8).length,
                    itemBuilder: (context, index) {
                      final category = categoryController.categories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 12),
      child: ShamraCard(
        onTap: () => Get.toNamed('/category-products', arguments: category),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.category_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.displayName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildSubCategoriesSection() {
    return SliverToBoxAdapter(
      child: GetBuilder<SubCategoryController>(
        init: SubCategoryController(),
        builder: (subCategoryController) => Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الفئات الفرعية',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/sub-categories'),
                      child: const Text('عرض الكل'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (subCategoryController.isLoading) {
                  return _buildSubCategoriesShimmer();
                }

                if (subCategoryController.subCategories.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        'لا توجد فئات فرعية متاحة',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: subCategoryController.subCategories
                        .take(6)
                        .length,
                    itemBuilder: (context, index) {
                      final subCategory =
                          subCategoryController.subCategories[index];
                      return _buildSubCategoryCard(subCategory);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryCard(SubCategory subCategory) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(left: 12),
      child: ShamraCard(
        onTap: () =>
            Get.toNamed('/subcategory-products', arguments: subCategory),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.secondaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                subCategory.type == SubCategoryType.customAttr
                    ? Icons.tune_rounded
                    : Icons.label_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subCategory.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subCategory.typeDisplayName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection(MainController controller) {
    return SliverToBoxAdapter(
      child: Obx(
        () => _buildProductSection(
          title: 'المنتجات المميزة',
          icon: Icons.star_rounded,
          products: controller.featuredProducts,
          onSeeAll: () =>
              Get.toNamed('/products', arguments: {'featured': true}),
        ),
      ),
    );
  }

  Widget _buildOnSaleProductsSection(MainController controller) {
    return SliverToBoxAdapter(
      child: Obx(
        () => _buildProductSection(
          title: 'عروض خاصة',
          icon: Icons.local_offer_rounded,
          products: controller.onSaleProducts,
          onSeeAll: () => Get.toNamed('/products', arguments: {'onSale': true}),
        ),
      ),
    );
  }

  Widget _buildRecentProductsSection(MainController controller) {
    return SliverToBoxAdapter(
      child: Obx(
        () => _buildProductSection(
          title: 'أحدث المنتجات',
          icon: Icons.new_releases_rounded,
          products: controller.recentProducts,
          onSeeAll: () => Get.toNamed('/products'),
        ),
      ),
    );
  }

  Widget _buildProductSection({
    required String title,
    required IconData icon,
    required List<Product> products,
    required VoidCallback onSeeAll,
  }) {
    if (products.isEmpty) return const SizedBox.shrink();

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
                    Icon(icon, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                TextButton(onPressed: onSeeAll, child: const Text('عرض الكل')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  width: 180,
                  margin: const EdgeInsets.only(left: 12),
                  child: ProductCard(
                    product: product,
                    onTap: () =>
                        Get.toNamed('/product-details', arguments: product),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Column(
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.all(20),
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

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
            width: 100,
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

  Widget _buildSubCategoriesShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 4,
          itemBuilder: (context, index) => Container(
            width: 140,
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
