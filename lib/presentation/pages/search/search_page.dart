// lib/presentation/pages/search/search_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart' hide ErrorWidget, SearchController;
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/search_controller.dart';
import '../../widgets/product_card.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/search_widgets.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sc = Get.put(SearchController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'البحث',
          actions: [
            Obx(
              () => IconButton(
                tooltip: 'مسح البحث',
                onPressed: sc.searchQuery.isNotEmpty ? sc.clearSearch : null,
                icon: Icon(
                  Icons.close_rounded,
                  color: sc.searchQuery.isNotEmpty
                      ? AppColors.iconColor
                      : AppColors.iconColor.withOpacity(0.3),
                ),
              ),
            ),
            IconButton(
              tooltip: 'الفلاتر المتقدمة',
              onPressed: () => _openFiltersSheet(context, sc),
              icon: const Icon(Icons.tune_rounded, color: AppColors.iconColor),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // 🔎 شريط البحث
            ShamraCard(
              margin: const EdgeInsets.fromLTRB(16, 3, 16, 0),
              padding: const EdgeInsets.fromLTRB(16, 3, 16, 0),
              elevation: 2,
              child: ShamraTextField(
                hintText: 'ابحث عن منتج، فئة أو علامة تجارية…',
                icon: Icons.search_rounded,
                controller: sc.searchTextController,
                onChanged: (q) {},
                onSubmitted: (q) => sc.performSearch(q),
                suffixIcon: Obx(
                  () => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sc.searchQuery.isNotEmpty)
                        IconButton(
                          tooltip: 'بحث',
                          onPressed: () => sc.performSearch(sc.searchQuery),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔹 ملخص الفلاتر
            Obx(
              () => ActiveFiltersSummary(
                activeFilters: _activeFiltersList(sc),
                onClearAll: sc.clearAllFilters,
                onRemoveFilter: (f) => _removeSingleFilter(sc, f),
              ),
            ),

            // 🔹 رأس النتائج (لا يظهر قبل بحث فعلي)
            Obx(
              () => (sc.hasSearched || sc.resultsCount > 0)
                  ? SearchResultsHeader(
                      totalResults: sc.resultsCount,
                      query: sc.searchQuery,
                      isLoading: sc.isSearching,
                    )
                  : const SizedBox.shrink(),
            ),

            // ====================== المحتوى ======================
            Expanded(
              child: Obx(() {
                final isIdle =
                    !sc.hasSearched &&
                    sc.resultsCount == 0 &&
                    !sc.isSearching &&
                    sc.errorMessage.isEmpty &&
                    !sc.hasActiveFilters;

                if (sc.isSearching && sc.resultsCount == 0) {
                  return const LoadingWidget(message: 'جاري البحث…');
                }

                if (sc.errorMessage.isNotEmpty) {
                  return ErrorWidget(
                    message: sc.errorMessage,
                    onRetry: () => sc.performAdvancedSearch(),
                  );
                }

                if (isIdle) {
                  // شاشة اقتراحات: تاريخ + اقتراحات + الأكثر بحثًا
                  return _IdleSuggestions(sc: sc);
                }

                // لا تُظهر EmptySearchState إلا بعد بحث
                if (sc.hasSearched && sc.resultsCount == 0 && !sc.isSearching) {
                  return EmptySearchState(
                    query: sc.searchQuery,
                    suggestions: sc.searchSuggestions,
                    onSuggestionTap: sc.performQuickSearch,
                    onClearFilters: sc.clearAllFilters,
                    hasActiveFilters: sc.hasActiveFilters,
                  );
                }

                // شبكة النتائج + تحميل لانهائي
                return NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                      sc.loadMore();
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisExtent: 250,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = sc.filteredResults[index];
                            return ProductCard(
                              product: product,
                              isGridView: true,
                              onTap: () {
                                Get.toNamed(
                                  Routes.productDetails,
                                  arguments: product.id,
                                );
                              },
                            );
                          }, childCount: sc.filteredResults.length),
                        ),
                      ),

                      // مؤشر تحميل المزيد
                      SliverToBoxAdapter(
                        child: Obx(
                          () => sc.isLoadingMore
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: LoadingWidget(
                                    size: 28,
                                    message: 'تحميل المزيد…',
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // نهاية النتائج
                      SliverToBoxAdapter(
                        child: Obx(
                          () =>
                              (!sc.hasNextPage && sc.filteredResults.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Center(
                                    child: Text(
                                      'تم عرض كل النتائج',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------- Widgets & Helpers -----------------------------

  static List<String> _activeFiltersList(SearchController sc) {
    final desc = sc.getActiveFiltersDescription();
    if (desc == 'لا توجد فلاتر') return [];
    return desc
        .split(' | ')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static void _removeSingleFilter(SearchController sc, String filter) {
    if (filter.startsWith('الفئة:')) {
      sc.selectCategory('');
    } else if (filter.startsWith('الفئة الفرعية:')) {
      sc.selectSubCategory('');
    } else if (filter.startsWith('العلامة:')) {
      sc.selectBrand('');
    } else if (filter.startsWith('السعر:')) {
      sc.setPriceRange(sc.minPrice, sc.maxPrice);
    } else if (filter == 'متوفر') {
      if (sc.showOnlyInStock) sc.toggleStockFilter();
    } else if (filter == 'عروض') {
      if (sc.showOnlyOnSale) sc.toggleSaleFilter();
    } else if (filter == 'مميز') {
      if (sc.showOnlyFeatured) sc.toggleFeaturedFilter();
    }
    // بعد إزالة الفلتر، أعد البحث
    sc.performAdvancedSearch();
  }

  static Future<void> _openFiltersSheet(
    BuildContext context,
    SearchController sc,
  ) async {
    await ShamraBottomSheet.show(
      context: context,
      title: 'الفلاتر المتقدمة',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ShamraButton(
            text: 'مسح',
            isOutlined: true,
            icon: Icons.filter_alt_off_rounded,
            onPressed: () {
              sc.clearAllFilters();
              Navigator.of(context).pop();
            },
          ),
        ),
        ShamraButton(
          text: 'تطبيق',
          icon: Icons.done_all_rounded,
          onPressed: () {
            sc.performAdvancedSearch();
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Obx(() {
        // اشتقاق العلامات التجارية من النتائج الحالية
        final brandsFromResults =
            sc.filteredResults
                .map((p) => (p.brand ?? '').trim())
                .where((b) => b.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

        final allBrands =
            (sc.brands.toList() + brandsFromResults).toSet().toList()..sort();

        final min = sc.minPrice;
        final max = sc.maxPrice;
        final start = math.max(min, sc.currentMinPrice);
        final end = math.min(max, sc.currentMaxPrice);

        return SingleChildScrollView(
          child: Column(
            children: [
              // ----------------- الفئات -----------------
              FilterSectionHeader(
                title: 'الفئات',
                icon: Icons.category_rounded,
                description: 'اختر فئة رئيسية ثم الفئة الفرعية',
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: sc.selectedCategoryId.isNotEmpty
                          ? sc.selectedCategoryId
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'الفئة',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: sc.categories
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(
                                c.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => sc.selectCategory(v ?? ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: sc.selectedSubCategoryId.isNotEmpty
                          ? sc.selectedSubCategoryId
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'الفئة الفرعية',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: sc.subCategories
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s.id,
                              child: Text(
                                s.displayName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: sc.subCategories.isNotEmpty
                          ? (v) => sc.selectSubCategory(v ?? '')
                          : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const ShamraDivider(),

              // ----------------- العلامة التجارية + الترتيب -----------------
              FilterSectionHeader(
                title: 'العلامات والترتيب',
                icon: Icons.sell_rounded,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value:
                          (allBrands.isNotEmpty &&
                              sc.selectedBrand.isNotEmpty &&
                              allBrands.contains(sc.selectedBrand))
                          ? sc.selectedBrand
                          : null,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'العلامة التجارية',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: allBrands
                          .map(
                            (b) => DropdownMenuItem<String>(
                              value: b,
                              child: Text(b, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => sc.selectBrand(v ?? ''),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: sc.sortBy,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'ترتيب حسب',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'relevance',
                          child: Text('الأكثر صلة'),
                        ),
                        DropdownMenuItem(
                          value: 'price_low_high',
                          child: Text('السعر: من الأقل للأعلى'),
                        ),
                        DropdownMenuItem(
                          value: 'price_high_low',
                          child: Text('السعر: من الأعلى للأقل'),
                        ),
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('الأحدث'),
                        ),
                        DropdownMenuItem(
                          value: 'name_asc',
                          child: Text('الاسم أ-ي'),
                        ),
                        DropdownMenuItem(
                          value: 'name_desc',
                          child: Text('الاسم ي-أ'),
                        ),
                        DropdownMenuItem(
                          value: 'popularity',
                          child: Text('الشعبية'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) sc.setSortBy(v);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const ShamraDivider(),

              // ----------------- السعر -----------------
              FilterSectionHeader(
                title: 'نطاق السعر',
                icon: Icons.attach_money_rounded,
                description: 'حرّك الشريط أو اختر نطاقًا سريعًا',
              ),
              InteractivePriceRangeSlider(
                minValue: min,
                maxValue: max,
                currentMin: start,
                currentMax: end,
                onChanged: (a, b) => sc.setPriceRange(a, b),
                currency: '\$',
              ),

              const SizedBox(height: 20),
              const ShamraDivider(),

              // ----------------- فلاتر سريعة -----------------
              FilterSectionHeader(
                title: 'فلاتر سريعة',
                icon: Icons.bolt_rounded,
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  AdvancedFilterChip(
                    label: 'متوفر فقط',
                    icon: Icons.inventory_2_rounded,
                    isSelected: sc.showOnlyInStock,
                    onTap: sc.toggleStockFilter,
                  ),
                  AdvancedFilterChip(
                    label: 'عروض فقط',
                    icon: Icons.local_offer_rounded,
                    isSelected: sc.showOnlyOnSale,
                    onTap: sc.toggleSaleFilter,
                  ),
                  AdvancedFilterChip(
                    label: 'منتجات مميزة',
                    icon: Icons.star_rounded,
                    isSelected: sc.showOnlyFeatured,
                    onTap: sc.toggleFeaturedFilter,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _IdleSuggestions extends StatelessWidget {
  final SearchController sc;

  const _IdleSuggestions({required this.sc});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تاريخ البحث
          FilterSectionHeader(
            title: 'سجل البحث',
            icon: Icons.history_rounded,
            action: sc.searchHistory.isNotEmpty
                ? TextButton(
                    onPressed: sc.clearSearchHistory,
                    child: const Text('مسح الكل'),
                  )
                : null,
          ),
          Obx(
            () => sc.searchHistory.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text('لا يوجد سجل بحث بعد.'),
                  )
                : Column(
                    children: sc.searchHistory
                        .map(
                          (h) => SearchHistoryItem(
                            query: h,
                            timestamp: DateTime.now(),
                            showTime: false,
                            onTap: () => sc.performQuickSearch(h),
                            onRemove: () => sc.removeFromHistory(h),
                          ),
                        )
                        .toList(),
                  ),
          ),

          const SizedBox(height: 20),
          const ShamraDivider(),

          // البحثات الشائعة
          FilterSectionHeader(
            title: 'البحثات الشائعة',
            icon: Icons.trending_up_rounded,
          ),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sc.popularSearches
                  .map(
                    (p) => ShamraChip(
                      label: p,
                      onTap: () => sc.performQuickSearch(p),
                      icon: Icons.trending_up_rounded,
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 24),
          // حالة فارغة لطيفة مع الشعار
          ShamraCard(
            elevation: 1,
            child: Column(
              children: const [
                SizedBox(height: 8),
                ShamraLogo(size: 90),
                SizedBox(height: 14),
                Text(
                  'ابحث عن أي منتج بسهولة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'اكتب اسم المنتج أو اختر فئة ثم طبّق فلاتر السعر والعلامات التجارية.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
