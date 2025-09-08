import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';
import '../../../data/models/sub_category.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedCategoryId = '';
  String _selectedSubCategoryId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: const Text(
            'المنتجات',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'المميزة'),
              Tab(text: 'العروض'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search and Filters
            _buildSearchAndFilters(),

            // Products Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllProductsTab(),
                  _buildFeaturedProductsTab(),
                  _buildSaleProductsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          ShamraTextField(
            label: '',
            hintText: 'ابحث عن المنتجات...',
            icon: Icons.search,
            controller: _searchController,
            onChanged: (value) {
              final productController = Get.find<ProductController>();
              if (value.isNotEmpty) {
                productController.searchProducts(value);
              } else {
                productController.clearSearch();
              }
            },
          ),

          const SizedBox(height: 12),

          // Filters Row
          Row(
            children: [
              Expanded(child: _buildCategoryFilter()),
              const SizedBox(width: 12),
              Expanded(child: _buildSubCategoryFilter()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return GetBuilder<CategoryController>(
      builder: (categoryController) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategoryId.isEmpty ? null : _selectedCategoryId,
            hint: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'اختر الفئة',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('جميع الفئات'),
                ),
              ),
              ...categoryController.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(category.displayName),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value ?? '';
                _selectedSubCategoryId = ''; // Reset subcategory
              });

              final productController = Get.find<ProductController>();
              final subCategoryController = Get.find<SubCategoryController>();

              if (value?.isNotEmpty == true) {
                productController.getProductsByCategory(value!);
                subCategoryController.loadSubCategoriesByCategory(value!);
              } else {
                productController.clearCategoryFilter();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryFilter() {
    return GetBuilder<SubCategoryController>(
      builder: (subCategoryController) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSubCategoryId.isEmpty
                ? null
                : _selectedSubCategoryId,
            hint: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'الفئة الفرعية',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            isExpanded: true,
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('جميع الفئات الفرعية'),
                ),
              ),
              ...subCategoryController.filteredSubCategories.map((subCategory) {
                return DropdownMenuItem<String>(
                  value: subCategory.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(subCategory.displayName),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSubCategoryId = value ?? '';
              });
              // Handle subcategory filter
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAllProductsTab() {
    return GetBuilder<ProductController>(
      init: ProductController(),
      builder: (controller) => Obx(() {
        if (controller.isLoading && controller.products.isEmpty) {
          return _buildProductsShimmer();
        }

        if (controller.products.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.inventory_2_outlined,
            title: 'لا توجد منتجات',
            message: 'لا توجد منتجات متاحة حالياً',
          );
        }

        return _buildProductGrid(controller.products, controller);
      }),
    );
  }

  Widget _buildFeaturedProductsTab() {
    return GetBuilder<ProductController>(
      builder: (controller) => Obx(() {
        if (controller.isLoading && controller.featuredProducts.isEmpty) {
          return _buildProductsShimmer();
        }

        if (controller.featuredProducts.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.star_outline,
            title: 'لا توجد منتجات مميزة',
            message: 'لا توجد منتجات مميزة حالياً',
          );
        }

        return _buildProductGrid(controller.featuredProducts, controller);
      }),
    );
  }

  Widget _buildSaleProductsTab() {
    return GetBuilder<ProductController>(
      builder: (controller) => Obx(() {
        if (controller.isLoading && controller.onSaleProducts.isEmpty) {
          return _buildProductsShimmer();
        }

        if (controller.onSaleProducts.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.local_offer_outlined,
            title: 'لا توجد عروض',
            message: 'لا توجد منتجات في العروض حالياً',
          );
        }

        return _buildProductGrid(controller.onSaleProducts, controller);
      }),
    );
  }

  Widget _buildProductGrid(
    List<Product> products,
    ProductController controller,
  ) {
    return RefreshIndicator(
      onRefresh: controller.refreshProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length + (controller.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == products.length) {
            // Load more indicator
            if (controller.isLoadingMore) {
              return const Center(child: LoadingWidget(size: 20));
            } else {
              // Trigger load more
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.loadMoreProducts();
              });
              return const SizedBox.shrink();
            }
          }

          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Get.toNamed('/product-details', arguments: product),
          );
        },
      ),
    );
  }

  Widget _buildProductsShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
