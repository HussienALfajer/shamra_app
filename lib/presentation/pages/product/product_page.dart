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

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _initializeControllers();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listen for scroll events to trigger load more
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      final controller = Get.find<ProductController>();
      if (!controller.isLoadingMore && controller.hasMoreData) {
        controller.loadMoreProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              /// شريط التطبيق المخصص
              _buildCustomAppBar(),

              /// محتوى التبويبات
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }

  /// تهيئة الـ Controllers
  void _initializeControllers() {
    // تسجيل Controllers إذا لم تكن مسجلة
    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
    if (!Get.isRegistered<ProductsUIController>()) {
      Get.put(ProductsUIController());
    }

    // التحقق من التبويبة المطلوبة من Arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('initialTab')) {
        final initialTab = args['initialTab'] as int;
        _switchToTabByIndex(initialTab);
      } else {
        // تحميل التبويبة الافتراضية (الكل)
        _switchToTabByIndex(0);
      }
    });
  }

  /// التبديل إلى تبويبة بالرقم مع استدعاء الدالة المناسبة
  void _switchToTabByIndex(int index) {
    try {
      final controller = Get.find<ProductController>();
      final uiController = Get.find<ProductsUIController>();

      ProductTab tab;
      switch (index) {
        case 1:
          tab = ProductTab.featured;
          break;
        case 2:
          tab = ProductTab.onSale;
          break;
        default:
          tab = ProductTab.all;
      }

      // تحديث UI Controller
      uiController.changeTab(index);

      // التبديل إلى التبويبة وتحميل البيانات المناسبة
      _switchToTabAndLoadData(tab);

    } catch (e) {
      print('خطأ في تبديل التبويبة: $e');
    }
  }

  /// التبديل إلى التبويبة وتحميل البيانات المناسبة
  Future<void> _switchToTabAndLoadData(ProductTab tab) async {
    final controller = Get.find<ProductController>();

    try {
      switch (tab) {
        case ProductTab.featured:
          await controller.switchToTab(ProductTab.featured);
          // إذا لم تكن البيانات محملة، قم بتحميلها
          if (!controller.isCurrentTabLoaded) {
            await _loadFeaturedProducts();
          }
          break;
        case ProductTab.onSale:
          await controller.switchToTab(ProductTab.onSale);
          // إذا لم تكن البيانات محملة، قم بتحميلها
          if (!controller.isCurrentTabLoaded) {
            await _loadOnSaleProducts();
          }
          break;
        default:
          await controller.switchToTab(ProductTab.all);
          // إذا لم تكن البيانات محملة، قم بتحميلها
          if (!controller.isCurrentTabLoaded) {
            await _loadAllProducts();
          }
      }
    } catch (e) {
      print('خطأ في تحميل بيانات التبويبة: $e');
    }
  }

  /// تحميل جميع المنتجات
  Future<void> _loadAllProducts() async {
    final controller = Get.find<ProductController>();
    await controller.switchToTab(ProductTab.all);
  }

  /// تحميل المنتجات المميزة
  Future<void> _loadFeaturedProducts() async {
    final controller = Get.find<ProductController>();
    await controller.switchToTab(ProductTab.featured);
  }

  /// تحميل المنتجات المخفضة
  Future<void> _loadOnSaleProducts() async {
    final controller = Get.find<ProductController>();
    await controller.switchToTab(ProductTab.onSale);
  }

  /// بناء شريط التطبيق المخصص
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

          /// شريط البحث والفلاتر (للتبويبة "الكل" فقط)
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
                // زر مسح الفلاتر (يظهر فقط في التبويبة "الكل")
                GetBuilder<ProductController>(
                  builder: (controller) {
                    if (!controller.filtersAvailableForCurrentTab ||
                        !controller.hasActiveFilters) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ShamraChip(
                        label: 'مسح الفلاتر',
                        icon: Icons.clear_all_rounded,
                        onTap: () => _clearAllFilters(),
                      ),
                    );
                  },
                ),

                /// أيقونة البحث (تظهر فقط للتبويبة "الكل")
                GetBuilder<ProductController>(
                  builder: (controller) {
                    if (!controller.filtersAvailableForCurrentTab) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: _buildActionButton(
                        icon: uiController.showSearchField
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        isActive: uiController.showSearchField,
                        onPressed: () => uiController.toggleSearch(),
                      ),
                    );
                  },
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

  /// بناء زر العمل
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
    return GetBuilder<ProductsUIController>(
      builder: (uiController) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildTabItem('الكل', 0, uiController),
            _buildTabItem('المميزة', 1, uiController),
            _buildTabItem('العروض', 2, uiController),
          ],
        ),
      ),
    );
  }

  /// بناء عنصر التبويب
  Widget _buildTabItem(String title, int index, ProductsUIController uiController) {
    final isSelected = uiController.currentTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index, uiController),
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

  /// معالج النقر على التبويبة
  void _onTabTapped(int index, ProductsUIController uiController) {
    if (index != uiController.currentTabIndex) {
      // Reset scroll position when switching tabs
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      _switchToTabByIndex(index);
    }
  }

  /// بناء شريط البحث والفلاتر (للتبويبة "الكل" فقط)
  Widget _buildSearchAndFilters() {
    return GetBuilder<ProductsUIController>(
      builder: (uiController) => GetBuilder<ProductController>(
        builder: (controller) {
          // إخفاء الفلاتر إذا لم تكن متاحة للتبويبة الحالية
          if (!controller.filtersAvailableForCurrentTab) {
            return const SizedBox.shrink();
          }

          return AnimatedContainer(
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
          );
        },
      ),
    );
  }

  /// بناء حقل البحث
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
                (subCategory) => _buildDropdownItem(subCategory.id, subCategory.displayName),
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

  /// مسح جميع الفلاتر
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

  /// بناء محتوى التبويبات
  Widget _buildTabContent() {
    return GetBuilder<ProductController>(
      builder: (controller) => Obx(() {
        // حالة التحميل
        if (controller.isLoading && controller.currentProducts.isEmpty) {
          return _buildProductsShimmer();
        }

        // حالة عدم وجود منتجات
        if (controller.currentProducts.isEmpty) {
          return EmptyStateWidget(
            icon: _getEmptyStateIcon(controller.currentTab),
            title: _getEmptyStateTitle(controller.currentTab),
            message: _getEmptyStateMessage(controller.currentTab, controller),
          );
        }

        // عرض شبكة المنتجات مع ScrollController
        return _buildProductGrid(controller.currentProducts, controller);
      }),
    );
  }

  /// الحصول على أيقونة الحالة الفارغة
  IconData _getEmptyStateIcon(ProductTab tab) {
    switch (tab) {
      case ProductTab.featured:
        return Icons.star_outline;
      case ProductTab.onSale:
        return Icons.local_offer_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  /// الحصول على عنوان الحالة الفارغة
  String _getEmptyStateTitle(ProductTab tab) {
    switch (tab) {
      case ProductTab.featured:
        return 'لا توجد منتجات مميزة';
      case ProductTab.onSale:
        return 'لا توجد عروض';
      default:
        return 'لا توجد منتجات';
    }
  }

  /// الحصول على رسالة الحالة الفارغة
  String _getEmptyStateMessage(ProductTab tab, ProductController controller) {
    if (controller.searchQuery.isNotEmpty) {
      return 'لا توجد نتائج للبحث عن "${controller.searchQuery}"';
    }

    switch (tab) {
      case ProductTab.featured:
        return 'لا توجد منتجات مميزة حالياً';
      case ProductTab.onSale:
        return 'لا توجد منتجات في العروض حالياً';
      default:
        if (controller.currentCategoryId.isNotEmpty) {
          if (controller.currentSubCategoryId.isNotEmpty) {
            return 'لا توجد منتجات في هذه الفئة الفرعية';
          }
          return 'لا توجد منتجات في هذه الفئة';
        }
        return 'لا توجد منتجات متاحة حالياً';
    }
  }

  /// بناء شبكة المنتجات مع ScrollController
  Widget _buildProductGrid(List<Product> products, ProductController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshCurrentTab(),
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      child: GridView.builder(
        controller: _scrollController, // استخدام ScrollController
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.56,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
        ),
        itemCount: products.length + (controller.hasMoreData && controller.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          /// مؤشر التحميل للصفحات التالية
          if (index == products.length && controller.hasMoreData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: LoadingWidget(size: 20),
              ),
            );
          }

          /// كارت المنتج
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Get.toNamed(Routes.productDetails, arguments: product.id),
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
}

/// Controller محسن لإدارة حالة واجهة المستخدم
class ProductsUIController extends GetxController {
  /// متحكم النص للبحث
  final searchController = TextEditingController();

  /// حالات الواجهة التفاعلية
  final RxBool _showSearchField = false.obs;
  final RxString _selectedCategoryId = ''.obs;
  final RxString _selectedSubCategoryId = ''.obs;
  final RxInt _currentTabIndex = 0.obs;

  /// Getters
  bool get showSearchField => _showSearchField.value;
  String get selectedCategoryId => _selectedCategoryId.value;
  String get selectedSubCategoryId => _selectedSubCategoryId.value;
  int get currentTabIndex => _currentTabIndex.value;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// تغيير التبويبة
  void changeTab(int index) {
    if (_currentTabIndex.value != index) {
      _currentTabIndex.value = index;

      // إخفاء البحث عند تغيير التبويبة
      if (_showSearchField.value) {
        _showSearchField.value = false;
      }

      // مسح الفلاتر عند تغيير التبويبة
      clearAllFilters();
      update();
    }
  }

  /// تبديل عرض حقل البحث
  void toggleSearch() {
    _showSearchField.value = !_showSearchField.value;
    if (!_showSearchField.value) {
      clearSearch();
    }
    update();
  }

  /// مسح البحث
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

  /// تغيير نص البحث
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

  /// تغيير الفئة المحددة
  void onCategoryChanged(String? value) {
    _selectedCategoryId.value = value ?? '';
    _selectedSubCategoryId.value = '';

    try {
      final productController = Get.find<ProductController>();
      final subCategoryController = Get.find<SubCategoryController>();

      if (value?.isNotEmpty == true) {
        productController.getProductsByCategory(value!);
        subCategoryController.loadSubCategoriesByCategory(value);
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

  /// مسح جميع الفلاتر
  void clearAllFilters() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    searchController.clear();
    update();
  }
}