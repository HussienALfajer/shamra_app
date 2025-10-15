import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/sub_category_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';
import '../../../data/models/product.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة الـ Controllers
    _initializeControllers();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: _onWillPopProducts,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                /// شريط التطبيق المخصص
                _buildCustomAppBar(),

                /// محتوى التبويبات (الآن يدعم السحب)
                Expanded(child: _buildTabContent()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// تهيئة الـ Controllers
  void _initializeControllers() {
    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
    if (!Get.isRegistered<ProductsUIController>()) {
      Get.put(ProductsUIController());
    }

    // تهيئة البيانات الأولية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uiController = Get.find<ProductsUIController>();
      final args = Get.arguments as Map<String, dynamic>?;
      final initialTab = (args != null && args.containsKey('initialTab'))
          ? (args['initialTab'] as int)
          : 0;

      uiController.initializePageController(initialTab);
      _switchToTabByIndex(initialTab);
    });
  }

  /// التبديل إلى تبويبة بالرقم مع استدعاء الدالة المناسبة (منطق فقط؛ بدون تحريك الصفحة)
  void _switchToTabByIndex(int index) {
    try {
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

      // تحديث مؤشر الواجهة
      uiController.changeTab(index);

      // تحميل بيانات التبويب المناسب
      _switchToTabAndLoadData(tab);
    } catch (e) {
      // ignore: avoid_print
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
          if (!controller.isCurrentTabLoaded) {
            await _loadFeaturedProducts();
          }
          break;
        case ProductTab.onSale:
          await controller.switchToTab(ProductTab.onSale);
          if (!controller.isCurrentTabLoaded) {
            await _loadOnSaleProducts();
          }
          break;
        default:
          await controller.switchToTab(ProductTab.all);
          if (!controller.isCurrentTabLoaded) {
            await _loadAllProducts();
          }
      }
    } catch (e) {
      // ignore: avoid_print
      print('خطأ في تحميل بيانات التبويبة: $e');
    }
  }

  Future<void> _loadAllProducts() async {
    final controller = Get.find<ProductController>();
    await controller.switchToTab(ProductTab.all);
  }

  Future<void> _loadFeaturedProducts() async {
    final controller = Get.find<ProductController>();
    await controller.switchToTab(ProductTab.featured);
  }

  Future<void> _loadOnSaleProducts() async {
    final controller = Get.find<ProductController>();
    await controller.switchToTab(ProductTab.onSale);
  }

  Future<bool> _onWillPopProducts() async {
    final ui = Get.find<ProductsUIController>();
    if (ui.currentTabIndex > 0) {
      final scrollController = Get.find<MainController>().productsScrollController;
      if (scrollController.hasClients) {
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut);
      }
      // الانتقال للتبويب السابق بالسحب العكسي
      ui.pageController.animateToPage(
        ui.currentTabIndex - 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      return false;
    }

    final main = Get.find<MainController>();
    if (main.currentIndex.value != 0) {
      main.onNavTap(0);
      return false;
    }

    return true;
  }

  /// شريط التطبيق المخصص
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

          /// شريط البحث والفلاتر
          _buildSearchAndFilters(),
        ],
      ),
    );
  }

  /// رأس شريط التطبيق
  Widget _buildAppBarHeader() {
    return GetBuilder<ProductsUIController>(
      builder: (uiController) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'قسم المنتجات',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 1.2,
              ),
            ),
            Row(
              children: [
                GetBuilder<ProductController>(
                  builder: (controller) {
                    if (!controller.hasActiveFilters) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: ShamraChip(
                        label: 'مسح الفلاتر',
                        icon: Icons.clear_all_rounded,
                        onTap: () => _clearAllFilters(),
                      ),
                    );
                  },
                ),
                GetBuilder<ProductController>(
                  builder: (controller) {
                    // البحث متاح لكل التبويبات الآن
                    if (!controller.searchAvailableForCurrentTab) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 2),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

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
            ? AppColors.grey.withOpacity(0.1)
            : AppColors.white.withOpacity(0.08),
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

  Widget _buildTabItem(
      String title, int index, ProductsUIController uiController) {
    final isSelected = uiController.currentTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          final scrollController = Get.find<MainController>().productsScrollController;
          if (scrollController.hasClients) {
            scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
          uiController.pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
          );
        },
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
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// شريط البحث والفلاتر - محدث للبحث في كل التبويبات
  Widget _buildSearchAndFilters() {
    return GetBuilder<ProductsUIController>(
      builder: (uiController) => GetBuilder<ProductController>(
        builder: (controller) {
          // البحث متاح لكل التبويبات، الفلاتر متاحة فقط للتبويب "الكل"
          if (!controller.searchAvailableForCurrentTab) {
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
                  // حقل البحث متاح لكل التبويبات
                  _buildSearchField(uiController),

                  // الفلاتر (الفئات والفئات الفرعية) متاحة فقط للتبويب "الكل"
                  if (controller.categoryFiltersAvailableForCurrentTab) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                            child: _buildCategoryFilter(uiController)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildSubCategoryFilter(uiController)),
                      ],
                    ),
                  ],
                ],
              ),
            )
                : const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(ProductsUIController uiController) {
    return GetBuilder<ProductController>(
      builder: (controller) {
        String hintText = 'ابحث عن المنتجات...';

        // تخصيص نص البحث حسب التبويب
        switch (controller.currentTab) {
          case ProductTab.featured:
            hintText = 'ابحث في المنتجات المميزة...';
            break;
          case ProductTab.onSale:
            hintText = 'ابحث في العروض...';
            break;
          case ProductTab.all:
            if (controller.currentCategoryId.isNotEmpty) {
              hintText = 'ابحث في هذه الفئة...';
            } else {
              hintText = 'ابحث عن المنتجات...';
            }
            break;
        }

        return ShamraTextField(
          hintText: hintText,
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
      },
    );
  }

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
                (category) =>
                _buildDropdownItem(category.id, category.displayName),
          ),
        ],
        onChanged: (value) => uiController.onCategoryChanged(value),
      ),
    );
  }

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
      ).applyKey(ValueKey(uiController.selectedCategoryId)),
    );
  }

  /// القائمة المنسدلة العامة
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

  void _clearAllFilters() {
    try {
      final productController = Get.find<ProductController>();
      final subCategoryController = Get.find<SubCategoryController>();
      final uiController = Get.find<ProductsUIController>();

      uiController.clearAllFilters();
      productController.clearAllFilters();
      subCategoryController.clearFilters();

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

  /// محتوى التبويبات مع دعم السحب
  Widget _buildTabContent() {
    return GetBuilder<ProductsUIController>(
      builder: (uiController) => PageView(
        controller: uiController.pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          // تحديث التبويب وتحميل بياناته عند انتهاء السحب
          _switchToTabByIndex(index);
        },
        children: [
          _buildProductsBody(),
          _buildProductsBody(),
          _buildProductsBody(),
        ],
      ),
    );
  }

  /// جسم صفحة المنتجات (يستخدم حالة التبويب الحالي داخل ProductController)
  Widget _buildProductsBody() {
    return GetBuilder<ProductController>(
      builder: (controller) {
        // RefreshIndicator متاح في جميع الحالات
        return RefreshIndicator(
          onRefresh: () => controller.refreshCurrentTab(),
          color: AppColors.primary,
          backgroundColor: AppColors.white,
          child: Builder(
            builder: (context) {
              if (controller.isLoading && controller.currentProducts.isEmpty) {
                return _buildRefreshableShimmer();
              }

              if (controller.currentProducts.isEmpty) {
                return _buildRefreshableEmptyState(controller);
              }

              return _buildProductGrid(controller.currentProducts, controller, showRefreshIndicator: false);
            },
          ),
        );
      },
    );
  }

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

  String _getEmptyStateMessage(ProductTab tab, ProductController controller) {
    if (controller.searchQuery.isNotEmpty) {
      String searchContext = '';
      switch (tab) {
        case ProductTab.featured:
          searchContext = ' في المنتجات المميزة';
          break;
        case ProductTab.onSale:
          searchContext = ' في العروض';
          break;
        case ProductTab.all:
          if (controller.currentCategoryId.isNotEmpty) {
            searchContext = ' في هذه الفئة';
          }
          break;
      }
      return 'لا توجد نتائج للبحث عن "${controller.searchQuery}"$searchContext';
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

  Widget _buildProductGrid(
      List<Product> products,
      ProductController controller,
      {bool showRefreshIndicator = true}) {
    final scrollController = Get.find<MainController>().productsScrollController;

    final gridView = GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
      ),
      itemCount: products.length + (controller.hasMoreData && controller.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length && controller.hasMoreData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingWidget(size: 20),
            ),
          );
        }

        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => Get.toNamed(Routes.productDetails, arguments: product.id),
        );
      },
    );

    // إذا كان RefreshIndicator مطلوب، نضعه، وإلا نعرض GridView مباشرة
    return showRefreshIndicator
        ? RefreshIndicator(
      onRefresh: () => controller.refreshCurrentTab(),
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      child: gridView,
    )
        : gridView;
  }

  /// Shimmer قابل للتحديث
  Widget _buildRefreshableShimmer() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
          ),
          const SizedBox(height: 100), // مساحة إضافية للتأكد من إمكانية السحب
        ],
      ),
    );
  }

  /// Empty state قابل للتحديث
  Widget _buildRefreshableEmptyState(ProductController controller) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(Get.context!).size.height - 300, // تقليل الارتفاع المطلوب
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmptyStateWidget(
                icon: _getEmptyStateIcon(controller.currentTab),
                title: _getEmptyStateTitle(controller.currentTab),
                message: _getEmptyStateMessage(controller.currentTab, controller),
              ),
              const SizedBox(height: 20),
              // زر تحديث إضافي للوضوح
              ElevatedButton.icon(
                onPressed: () => controller.refreshCurrentTab(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تحديث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Controller لمحاذاة واجهة المستخدم - محدث للبحث في كل التبويبات
class ProductsUIController extends GetxController {
  final searchController = TextEditingController();
  late PageController _pageController;

  final RxBool _showSearchField = false.obs;
  final RxString _selectedCategoryId = ''.obs;
  final RxString _selectedSubCategoryId = ''.obs;
  final RxInt _currentTabIndex = 0.obs;

  bool get showSearchField => _showSearchField.value;
  String get selectedCategoryId => _selectedCategoryId.value;
  String get selectedSubCategoryId => _selectedSubCategoryId.value;
  int get currentTabIndex => _currentTabIndex.value;
  PageController get pageController => _pageController;

  @override
  void onInit() {
    super.onInit();
    _pageController = PageController(initialPage: 0);
    _setupScrollListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    _pageController.dispose();
    _removeScrollListener();
    super.onClose();
  }

  /// تهيئة PageController مع الصفحة الأولية
  void initializePageController(int initialPage) {
    if (_pageController.hasClients && initialPage != _currentTabIndex.value) {
      _pageController.jumpToPage(initialPage);
    }
  }

  /// إعداد مستمع التمرير
  void _setupScrollListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final scrollController = Get.find<MainController>().productsScrollController;
        scrollController.addListener(_onScroll);
      } catch (e) {
        print('خطأ في إعداد مستمع التمرير: $e');
      }
    });
  }

  /// إزالة مستمع التمرير
  void _removeScrollListener() {
    try {
      final scrollController = Get.find<MainController>().productsScrollController;
      scrollController.removeListener(_onScroll);
    } catch (e) {
      print('خطأ في إزالة مستمع التمرير: $e');
    }
  }

  /// معالج أحداث التمرير
  void _onScroll() {
    try {
      final scrollController = Get.find<MainController>().productsScrollController;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        final productController = Get.find<ProductController>();
        if (!productController.isLoadingMore && productController.hasMoreData) {
          productController.loadMoreProducts();
        }
      }
    } catch (e) {
      print('خطأ في معالجة التمرير: $e');
    }
  }

  void changeTab(int index) {
    if (_currentTabIndex.value != index) {
      _currentTabIndex.value = index;

      // إخفاء البحث عند تغيير التبويب
      if (_showSearchField.value) {
        _showSearchField.value = false;
      }

      // مسح الفلاتر فقط إذا انتقلنا من/إلى التبويب "الكل"
      if (index != 0 || _currentTabIndex.value == 0) {
        clearFiltersOnly(); // مسح الفلاتر فقط وليس البحث
      }

      update();
    }
  }

  void toggleSearch() {
    _showSearchField.value = !_showSearchField.value;
    if (!_showSearchField.value) {
      clearSearch();
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    try {
      final productController = Get.find<ProductController>();
      productController.clearSearch();
    } catch (_) {}
  }

  void onSearchChanged(String value) {
    try {
      final productController = Get.find<ProductController>();
      productController.searchProducts(value);
    } catch (_) {}
  }

  void onCategoryChanged(String? value) async {
    _selectedCategoryId.value = value ?? '';
    _selectedSubCategoryId.value = '';

    try {
      final productController = Get.find<ProductController>();
      final subCategoryController = Get.find<SubCategoryController>();

      if (value?.isNotEmpty == true) {
        subCategoryController.clearFilters();
        update();

        await subCategoryController.loadSubCategoriesByCategory(value!);

        await productController.getProductsByCategory(value!);
      } else {
        productController.clearCategoryFilter();
        subCategoryController.clearFilters();
      }
    } catch (_) {}
    update();
  }

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
    } catch (_) {}
    update();
  }

  /// مسح الفلاتر فقط (الفئات والفئات الفرعية) وليس البحث
  void clearFiltersOnly() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    update();
  }

  /// مسح كل شيء (البحث والفلاتر)
  void clearAllFilters() {
    _selectedCategoryId.value = '';
    _selectedSubCategoryId.value = '';
    searchController.clear();
    update();
  }
}

extension _WithKey on Widget {
  Widget applyKey(Key key) => KeyedSubtree(key: key, child: this);
}