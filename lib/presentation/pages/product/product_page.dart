import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/product.dart';

/// صفحة المنتجات الرئيسية مع نظام التبويبات والفلترة
/// تعرض المنتجات في ثلاث تبويبات: الكل، المميزة، العروض
/// تدعم البحث والفلترة حسب الفئات والفئات الفرعية
class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة الـ Controllers عند بناء الصفحة
    _initializeControllers();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              /// شريط التطبيق المخصص مع البحث والتبويبات
              _buildCustomAppBar(),

              /// محتوى التبويبات (المنتجات)
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  /// تهيئة الـ Controllers والبيانات
  void _initializeControllers() {
    // التأكد من وجود الـ Controllers
    if (!Get.isRegistered<ProductsTabController>()) {
      Get.put(ProductsTabController());
    }
    if (!Get.isRegistered<ProductsUIController>()) {
      Get.put(ProductsUIController());
    }

    // تحميل البيانات بشكل غير متزامن
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  /// تحميل البيانات الأولية
  Future<void> _loadInitialData() async {
    try {
      final productController = Get.find<ProductController>();

      // تحميل جميع أنواع المنتجات بشكل متوازي
      await Future.wait([
        productController.refreshProducts(),
        productController.loadFeaturedProducts(),
        productController.loadOnSaleProducts(),
      ]);

      // التحقق من التبويبة المطلوبة من Arguments
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('initialTab')) {
        final initialTab = args['initialTab'] as int;
        final tabController = Get.find<ProductsTabController>();
        if (initialTab >= 0 && initialTab < 3) {
          tabController.changeTab(initialTab);
        }
      }
    } catch (e) {
      // إظهار رسالة خطأ باستخدام ShamraSnackBar
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'خطأ في تحميل البيانات',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// بناء شريط التطبيق المخصص مع التبويبات
  Widget _buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          /// عنوان الصفحة والأيقونات
          _buildAppBarHeader(),

          /// شريط التبويبات
          _buildTabBar(),

          /// شريط البحث والفلاتر (يظهر عند الحاجة)
          _buildSearchAndFilters(),
        ],
      ),
    );
  }

  /// بناء رأس شريط التطبيق
  Widget _buildAppBarHeader() {
    return GetBuilder<ProductsUIController>(
      builder: (uiController) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// عنوان الصفحة
            const Text(
              'قسم المنتجات',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 1.2,
              ),
            ),

            /// أيقونات التحكم
            Row(
              children: [
                uiController.showSearchField
                    ? _buildClearFiltersButton()
                    : Container(),
                const SizedBox(width: 6),

                /// أيقونة البحث
                _buildActionButton(
                  icon: uiController.showSearchField
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  isActive: uiController.showSearchField,
                  onPressed: () => uiController.toggleSearch(),
                ),

                const SizedBox(width: 6),

                /// أيقونة الإشعارات
                _buildActionButton(
                  icon: Icons.notifications_outlined,
                  hasNotification: true,
                  onPressed: () => Get.toNamed(Routes.notifications),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// بناء زر العمل في شريط التطبيق
  Widget _buildActionButton({
    required IconData icon,
    bool isActive = false,
    bool hasNotification = false,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textPrimary,
              size: 22,
            ),
            padding: EdgeInsets.zero,
          ),

          /// نقطة الإشعار
          if (hasNotification)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// بناء شريط التبويبات
  Widget _buildTabBar() {
    return GetBuilder<ProductsTabController>(
      builder: (tabController) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildTabItem('الكل', 0, tabController),
            _buildTabItem('المميزة', 1, tabController),
            _buildTabItem('العروض', 2, tabController),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر التبويب الفردي
  Widget _buildTabItem(
      String title,
      int index,
      ProductsTabController controller,
      ) {
    final isSelected = controller.currentTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// بناء شريط البحث والفلاتر
  Widget _buildSearchAndFilters() {
    return GetBuilder<ProductsUIController>(
      builder: (uiController) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: uiController.showSearchField ? null : 0,
        child: uiController.showSearchField
            ? Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              /// حقل البحث
              _buildSearchField(uiController),
              const SizedBox(height: 10),

              /// فلاتر الفئات
              Row(
                children: [
                  Expanded(child: _buildCategoryFilter(uiController)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSubCategoryFilter(uiController)),
                ],
              ),
            ],
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// بناء حقل البحث باستخدام ShamraTextField
  Widget _buildSearchField(ProductsUIController uiController) {
    return ShamraTextField(
      hintText: 'ابحث عن المنتجات...',
      icon: Icons.search_rounded,
      controller: uiController.searchController,
      suffixIcon: uiController.searchController.text.isNotEmpty
          ? IconButton(
        onPressed: () => uiController.clearSearch(),
        icon: Icon(
          Icons.clear_rounded,
          color: AppColors.textSecondary.withOpacity(0.6),
          size: 20,
        ),
      )
          : null,
      onChanged: (value) => uiController.onSearchChanged(value),
    );
  }

  /// بناء فلتر الفئات الرئيسية
  Widget _buildCategoryFilter(ProductsUIController uiController) {
    return GetBuilder<CategoryController>(
      builder: (categoryController) => _buildDropdownFilter(
        hint: 'اختر الفئة',
        value: uiController.selectedCategoryId.isEmpty
            ? null
            : uiController.selectedCategoryId,
        items: [
          _buildDropdownItem('', 'جميع الفئات'),
          ...categoryController.categories.map(
                (category) => _buildDropdownItem(category.id, category.displayName),
          ),
        ],
        onChanged: (value) => uiController.onCategoryChanged(value),
      ),
    );
  }

  /// بناء فلتر الفئات الفرعية
  Widget _buildSubCategoryFilter(ProductsUIController uiController) {
    return GetBuilder<SubCategoryController>(
      builder: (subCategoryController) => _buildDropdownFilter(
        hint: 'الفئة الفرعية',
        value: uiController.selectedSubCategoryId.isEmpty
            ? null
            : uiController.selectedSubCategoryId,
        items: [
          _buildDropdownItem('', 'جميع الفئات الفرعية'),
          ...subCategoryController.filteredSubCategories.map(
                (subCategory) =>
                _buildDropdownItem(subCategory.id, subCategory.displayName),
          ),
        ],
        onChanged: (value) => uiController.onSubCategoryChanged(value),
      ),
    );
  }

  /// بناء القائمة المنسدلة العامة
  Widget _buildDropdownFilter({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 39,
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.05),
        border: Border.all(color: AppColors.grey.withOpacity(0.1), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              hint,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary.withOpacity(0.6),
              size: 24,
            ),
          ),
          dropdownColor: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// بناء عنصر في القائمة المنسدلة
  DropdownMenuItem<String> _buildDropdownItem(String value, String text) {
    return DropdownMenuItem<String>(
      value: value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withOpacity(0.8),
          ),
        ),
      ),
    );
  }

  /// بناء زر مسح جميع الفلاتر
  Widget _buildClearFiltersButton() {
    return GetBuilder<ProductController>(
      builder: (productController) => Obx(() {
        final hasActiveFilters =
            productController.searchQuery.isNotEmpty ||
                productController.currentCategoryId.isNotEmpty ||
                productController.currentSubCategoryId.isNotEmpty;

        if (!hasActiveFilters) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 1),
          child: ShamraChip(
            label: 'مسح الفلاتر',
            icon: Icons.clear_all_rounded,
            onTap: () => _clearAllFilters(),
          ),
        );
      }),
    );
  }

  /// مسح جميع الفلاتر المطبقة
  void _clearAllFilters() {
    try {
      final productController = Get.find<ProductController>();
      final subCategoryController = Get.find<SubCategoryController>();
      final uiController = Get.find<ProductsUIController>();

      // مسح جميع الفلاتر
      uiController.clearAllFilters();
      productController.clearAllFilters();
      subCategoryController.clearFilters();

      // إظهار رسالة تأكيد
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'تم مسح جميع الفلاتر',
          type: SnackBarType.success,
        );
      }
    } catch (e) {
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'خطأ في مسح الفلاتر',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// بناء محتوى التبويبات حسب التبويب المحدد
  Widget _buildTabContent() {
    return GetBuilder<ProductsTabController>(
      builder: (tabController) {
        switch (tabController.currentTabIndex) {
          case 1:
            return _buildFeaturedProductsTab();
          case 2:
            return _buildSaleProductsTab();
          default:
            return _buildAllProductsTab();
        }
      },
    );
  }

  /// بناء تبويبة جميع المنتجات
  Widget _buildAllProductsTab() {
    return GetBuilder<ProductController>(
      builder: (controller) => Obx(() {
        final productsToShow = controller.searchQuery.isNotEmpty
            ? controller.searchResults
            : controller.products;

        // حالة التحميل
        if (controller.isLoading && productsToShow.isEmpty) {
          return _buildProductsShimmer();
        }

        // حالة عدم وجود منتجات
        if (productsToShow.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.inventory_2_outlined,
            title: 'لا توجد منتجات',
            message: _getEmptyMessage(controller),
          );
        }

        // عرض شبكة المنتجات
        return _buildProductGrid(productsToShow, controller);
      }),
    );
  }

  /// بناء تبويبة المنتجات المميزة
  Widget _buildFeaturedProductsTab() {
    return GetBuilder<ProductController>(
      builder: (controller) => Obx(() {
        final productsToShow = controller.searchQuery.isNotEmpty
            ? controller.searchResults
            : controller.featuredProducts;
        // حالة التحميل
        if (controller.isLoading && productsToShow.isEmpty) {
          return _buildProductsShimmer();
        }

        // حالة عدم وجود منتجات مميزة
        if (productsToShow.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.star_outline,
            title: 'لا توجد منتجات مميزة',
            message: 'لا توجد منتجات مميزة حالياً',
          );
        }

        // عرض المنتجات المميزة
        return _buildProductGrid(productsToShow, controller);
      }),
    );
  }

  /// بناء تبويبة منتجات العروض
  Widget _buildSaleProductsTab() {
    return GetBuilder<ProductController>(
      builder: (controller) => Obx(() {
        // حالة التحميل
        if (controller.isLoading && controller.onSaleProducts.isEmpty) {
          return _buildProductsShimmer();
        }

        // حالة عدم وجود عروض
        if (controller.onSaleProducts.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.local_offer_outlined,
            title: 'لا توجد عروض',
            message: 'لا توجد منتجات في العروض حالياً',
          );
        }

        // عرض منتجات العروض
        return _buildProductGrid(controller.onSaleProducts, controller);
      }),
    );
  }

  /// بناء شبكة المنتجات مع دعم السحب للتحديث والتحميل اللانهائي
  Widget _buildProductGrid(
      List<Product> products,
      ProductController controller,
      ) {
    return RefreshIndicator(
      onRefresh: controller.refreshProducts,
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.56,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        itemCount: products.length + (controller.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          /// مؤشر التحميل للصفحات التالية
          if (index == products.length) {
            if (controller.isLoadingMore) {
              return const Center(child: LoadingWidget(size: 20));
            } else {
              /// تحميل المزيد من المنتجات تلقائياً
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.loadMoreProducts();
              });
              return const SizedBox.shrink();
            }
          }

          /// كارت المنتج الفردي
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Get.toNamed(Routes.productDetails, arguments: product),
          );
        },
      ),
    );
  }

  /// بناء مؤثر التحميل (Shimmer Effect)
  Widget _buildProductsShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: LoadingWidget(size: 30)),
      ),
    );
  }

  /// الحصول على رسالة الحالة الفارغة المناسبة
  String _getEmptyMessage(ProductController controller) {
    if (controller.searchQuery.isNotEmpty) {
      return 'لا توجد نتائج للبحث عن "${controller.searchQuery}"';
    } else if (controller.currentCategoryId.isNotEmpty) {
      if (controller.currentSubCategoryId.isNotEmpty) {
        return 'لا توجد منتجات في هذه الفئة الفرعية';
      }
      return 'لا توجد منتجات في هذه الفئة';
    }
    return 'لا توجد منتجات متاحة حالياً';
  }
}

/// Controller لإدارة حالة واجهة المستخدم للمنتجات
/// يتحكم في البحث والفلاتر وعرض/إخفاء العناصر
class ProductsUIController extends GetxController {
  /// متحكم النص للبحث
  final searchController = TextEditingController();

  /// حالات الواجهة التفاعلية
  final RxBool _showSearchField = false.obs;
  final RxString _selectedCategoryId = ''.obs;
  final RxString _selectedSubCategoryId = ''.obs;

  /// Getters للحصول على قيم الحالة
  bool get showSearchField => _showSearchField.value;

  String get selectedCategoryId => _selectedCategoryId.value;

  String get selectedSubCategoryId => _selectedSubCategoryId.value;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تبديل عرض حقل البحث
  void toggleSearch() {
    _showSearchField.value = !_showSearchField.value;
    if (!_showSearchField.value) {
      clearSearch();
    }
    update();
  }

  /// مسح البحث وإعادة تعيين النتائج
  void clearSearch() {
    searchController.clear();
    try {
      final productController = Get.find<ProductController>();
      productController.clearSearch();
    } catch (e) {
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'خطأ في مسح البحث',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// تغيير نص البحث وتشغيل البحث
  void onSearchChanged(String value) {
    try {
      final productController = Get.find<ProductController>();
      productController.searchProducts(value);
    } catch (e) {
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'خطأ في البحث',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// تغيير الفئة المحددة وتحديث المنتجات
  void onCategoryChanged(String? value) {
    _selectedCategoryId.value = value ?? '';
    _selectedSubCategoryId.value = '';

    try {
      final productController = Get.find<ProductController>();
      final subCategoryController = Get.find<SubCategoryController>();

      if (value?.isNotEmpty == true) {
        productController.getProductsByCategory(value!);

        /// تحميل الفئات الفرعية للفئة المحددة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          subCategoryController.loadSubCategoriesByCategory(value);
        });
      } else {
        productController.clearCategoryFilter();
        subCategoryController.clearFilters();
      }
    } catch (e) {
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'خطأ في تغيير الفئة',
          type: SnackBarType.error,
        );
      }
    }
    update();
  }

  /// تغيير الفئة الفرعية المحددة
  void onSubCategoryChanged(String? value) {
    _selectedSubCategoryId.value = value ?? '';

    try {
      final productController = Get.find<ProductController>();

      if (value?.isNotEmpty == true) {
        productController.filterBySubCategory(value!);
      } else {
        /// العودة لفلترة الفئة الرئيسية فقط
        if (_selectedCategoryId.isNotEmpty) {
          productController.getProductsByCategory(_selectedCategoryId.value);
        } else {
          productController.clearSubCategoryFilter();
        }
      }
    } catch (e) {
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'خطأ في تغيير الفئة الفرعية',
          type: SnackBarType.error,
        );
      }
    }
    update();
  }

  /// مسح جميع الفلاتر وإعادة تعيين الحالة
  void clearAllFilters() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    searchController.clear();
    update();
  }
}

/// Controller لإدارة التبويبات مع تحسين الأداء
/// يدير التنقل بين تبويبات: الكل، المميزة، العروض
class ProductsTabController extends GetxController {
  final RxInt _currentTabIndex = 0.obs;
  bool _isDataLoaded = false;

  /// Getters للحصول على الحالة الحالية
  int get currentTabIndex => _currentTabIndex.value;

  bool get isDataLoaded => _isDataLoaded;

  @override
  void onInit() {
    super.onInit();
    // تحميل البيانات عند إنشاء الـ controller
    _preloadData();
  }

  /// تحميل البيانات مسبقاً لتحسين الأداء
  Future<void> _preloadData() async {
    if (_isDataLoaded) return;

    try {
      final productController = Get.find<ProductController>();

      // تحميل جميع البيانات بشكل متوازي
      await Future.wait([
        productController.refreshProducts(),
        productController.loadFeaturedProducts(),
        productController.loadOnSaleProducts(),
      ]);

      _isDataLoaded = true;
    } catch (e) {
      if (Get.context != null) {
        ShamraSnackBar.show(
          context: Get.context!,
          message: 'خطأ في تحميل البيانات',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// تغيير التبويب المحدد مع مسح الفلاتر
  void changeTab(int index) {
    if (index != _currentTabIndex.value) {
      _currentTabIndex.value = index;

      // تحميل البيانات إذا لم تكن محملة
      if (!_isDataLoaded) {
        _preloadData();
      }

      /// مسح الفلاتر عند تغيير التبويب
      try {
        final uiController = Get.find<ProductsUIController>();
        uiController.clearAllFilters();

        /// مسح فلاتر المنتجات
        final productController = Get.find<ProductController>();
        final subCategoryController = Get.find<SubCategoryController>();

        productController.clearAllFilters();
        subCategoryController.clearFilters();
      } catch (e) {
        if (Get.context != null) {
          ShamraSnackBar.show(
            context: Get.context!,
            message: 'خطأ في مسح الفلاتر',
            type: SnackBarType.error,
          );
        }
      }

      update();
    }
  }
}