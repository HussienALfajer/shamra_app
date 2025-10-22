import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/product.dart';
import '../../../../data/utils/helpers.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/favorite_controller.dart';
import '../../controllers/product_controller.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/product_card.dart';

// NEW: Fullscreen zoomable image viewer
import '../../widgets/fullscreen_image_viewer.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with TickerProviderStateMixin {
  // Repository
  final ProductRepository _productRepository = ProductRepository();

  // Animation Controllers
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  // Page/Scroll Controllers
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  // Controllers
  final favController = Get.find<FavoriteController>();

  // Timers
  Timer? _autoSliderTimer;

  // State Variables
  int _currentImageIndex = 0;
  bool _isAppBarExpanded = true;
  bool _showFab = false;
  Product? product;
  bool isLoadingProduct = true;
  String productError = '';

  // Similar Products State
  List<Product> similarProducts = [];
  bool isLoadingSimilar = false;
  String similarProductsError = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadProductData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _autoSliderTimer?.cancel();
    super.dispose();
  }

  /// Initialize animations (fade-in, slide-up, FAB scale)
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  /// Setup scroll listener for app bar and FAB animations
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isExpanded = _scrollController.offset < 200;
      final shouldShowFab = _scrollController.offset > 300;

      if (isExpanded != _isAppBarExpanded) {
        setState(() {
          _isAppBarExpanded = isExpanded;
        });
      }

      if (shouldShowFab != _showFab) {
        setState(() {
          _showFab = shouldShowFab;
        });

        if (shouldShowFab) {
          _fabAnimationController.forward();
        } else {
          _fabAnimationController.reverse();
        }
      }
    });
  }

  /// Load product data from arguments
  Future<void> _loadProductData() async {
    try {
      final arguments = Get.arguments;

      if (arguments is String) {
        // Product ID passed - fetch product data
        final productData = await _productRepository.getProductById(arguments);

        if (mounted) {
          setState(() {
            if (productData != null) {
              product = productData;
              isLoadingProduct = false;
              productError = '';

              _startAnimations();
              _setupAutoSlider();
              _loadSimilarProducts();
            } else {
              isLoadingProduct = false;
              productError = 'المنتج غير موجود';
            }
          });
        }
      } else {
        // Invalid arguments
        if (mounted) {
          setState(() {
            isLoadingProduct = false;
            productError = 'خطأ في تحميل المنتج';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading product data: $e');
      if (mounted) {
        setState(() {
          isLoadingProduct = false;
          productError = 'فشل في تحميل المنتج';
        });
      }
    }
  }

  /// Start animations after product is loaded
  void _startAnimations() {
    _animationController.forward();
  }

  /// Setup auto slider for product images
  void _setupAutoSlider() {
    if (product?.images.isNotEmpty == true && product!.images.length > 1) {
      _autoSliderTimer?.cancel();
      _autoSliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients && mounted && product != null) {
          int nextPage = (_currentImageIndex + 1) % product!.images.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  /// Load similar products (staged approach: subcategory -> category -> price range)
  Future<void> _loadSimilarProducts() async {
    if (product == null) return;

    try {
      setState(() {
        isLoadingSimilar = true;
        similarProductsError = '';
      });

      List<Product> allProducts = [];

      // Stage 1: same subcategory
      if (product!.subCategoryId?.isNotEmpty == true) {
        final subCategoryResult = await _productRepository.getProducts(
          categoryId: product!.categoryId,
          limit: 50,
        );
        final subCategoryProducts =
            (subCategoryResult['products'] as List<Product>?)
                ?.where(
                  (p) =>
                      p.subCategoryId == product!.subCategoryId &&
                      p.id != product!.id,
                )
                .toList() ??
            [];
        allProducts.addAll(subCategoryProducts);
      }

      // Stage 2: same category if still lacking
      if (allProducts.length < 20) {
        final categoryResult = await _productRepository.getProducts(
          categoryId: product!.categoryId,
          limit: 100,
        );
        final categoryProducts =
            (categoryResult['products'] as List<Product>?)
                ?.where(
                  (p) =>
                      p.id != product!.id &&
                      !allProducts.any((existing) => existing.id == p.id),
                )
                .toList() ??
            [];
        allProducts.addAll(categoryProducts);
      }

      // Stage 3: price-range based
      if (allProducts.length < 20) {
        final priceRangeProducts = await _getSimilarPriceProducts();
        allProducts.addAll(
          priceRangeProducts.where(
            (p) => !allProducts.any((existing) => existing.id == p.id),
          ),
        );
      }

      // Sort by similarity score
      final sortedProducts = _sortProductsBySimilarity(allProducts);

      if (mounted) {
        setState(() {
          similarProducts = sortedProducts.take(20).toList();
          isLoadingSimilar = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading similar products: $e');
      if (mounted) {
        setState(() {
          isLoadingSimilar = false;
          similarProductsError = 'فشل في تحميل المنتجات المشابهة';
          similarProducts = [];
        });
      }
    }
  }

  /// Get products within ±30% price range
  Future<List<Product>> _getSimilarPriceProducts() async {
    final currentPrice = product!.displayPrice;
    final priceRange = currentPrice * 0.3;
    final minPrice = currentPrice - priceRange;
    final maxPrice = currentPrice + priceRange;

    try {
      final result = await _productRepository.getProducts(limit: 50);
      final products = result['products'] as List<Product>? ?? [];

      return products
          .where(
            (p) =>
                p.id != product!.id &&
                p.displayPrice >= minPrice &&
                p.displayPrice <= maxPrice,
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Sort products by similarity score (descending)
  List<Product> _sortProductsBySimilarity(List<Product> products) {
    return products..sort((a, b) {
      int scoreA = _calculateSimilarityScore(a);
      int scoreB = _calculateSimilarityScore(b);
      return scoreB.compareTo(scoreA);
    });
  }

  /// Similarity scoring heuristic
  int _calculateSimilarityScore(Product compareProduct) {
    int score = 0;

    if (compareProduct.subCategoryId == product!.subCategoryId) score += 50;
    if (compareProduct.categoryId == product!.categoryId) score += 30;
    if (compareProduct.brand == product!.brand &&
        product!.brand?.isNotEmpty == true) {
      score += 25;
    }

    final priceDifference =
        (compareProduct.displayPrice - product!.displayPrice).abs();
    final priceThreshold = product!.displayPrice * 0.3;
    if (priceDifference <= priceThreshold) score += 20;

    if (compareProduct.isFeatured == product!.isFeatured) score += 10;
    if (compareProduct.hasDiscount == product!.hasDiscount) score += 10;

    return score;
  }

  /// Open full-screen, zoomable gallery starting from tapped index
  void _openImageViewer(int startIndex) {
    final imgs =
        (product!.images.isNotEmpty ? product!.images : [product!.mainImage])
            .map((e) => HelperMethod.getImageUrl(e))
            .toList();

    Get.to(
      () => FullscreenImageViewer(
        images: imgs,
        initialIndex: startIndex,
        heroPrefix: 'product-${product!.id}-img-',
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _buildBody(),
        bottomNavigationBar: product != null ? _buildBottomBar() : null,
      ),
    );
  }

  Widget _buildBody() {
    if (isLoadingProduct) {
      return _buildLoadingState();
    }

    if (productError.isNotEmpty || product == null) {
      return _buildErrorState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Column(
                    children: [
                      _buildProductInfo(),
                      _buildPriceSection(),
                      _buildDescriptionSection(),
                      _buildSpecificationsSection(),
                      _buildStockInfo(),
                      _buildSimilarProducts(),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'تفاصيل المنتج',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: LoadingWidget(message: "جاري تحميل المنتج...", size: 50),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
        ),
        title: const Text(
          'تفاصيل المنتج',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: ShamraCard(
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                productError.isNotEmpty ? productError : 'فشل في تحميل المنتج',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShamraButton(
                    text: 'إعادة المحاولة',
                    onPressed: _loadProductData,
                    isOutlined: true,
                    width: 120,
                  ),
                  const SizedBox(width: 12),
                  ShamraButton(
                    text: 'العودة',
                    onPressed: () => Get.back(),
                    width: 120,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final images = product!.images.isNotEmpty
        ? product!.images
        : [product!.mainImage];

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(
            () => IconButton(
              icon: Icon(
                favController.isFavorite(product!.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: AppColors.error,
              ),
              onPressed: () {
                favController.toggleFavorite(product!.id);
                ShamraSnackBar.show(
                  context: context,
                  message: favController.isFavorite(product!.id)
                      ? 'تمت إضافة المنتج إلى المفضلة'
                      : 'تمت إزالة المنتج من المفضلة',
                  type: favController.isFavorite(product!.id)
                      ? SnackBarType.success
                      : SnackBarType.info,
                );
              },
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.white, AppColors.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Product Images (tap to open viewer, with Hero transition)
              if (images.isNotEmpty)
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = HelperMethod.getImageUrl(images[index]);
                      final heroTag =
                          'product-${product!.id}-img-$index'; // MUST match viewer prefix

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GestureDetector(
                            onTap: () => _openImageViewer(index),
                            child: Hero(
                              tag: heroTag,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Container(
                                  color: AppColors.lightGrey.withOpacity(0.3),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.lightGrey.withOpacity(0.3),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        size: 64,
                                        color: AppColors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'صورة غير متاحة',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Image Indicators
              if (images.length > 1)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: images.asMap().entries.map((entry) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == entry.key
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Discount Badge
              if (product!.hasDiscount)
                Positioned(
                  top: 100,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.red.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_offer_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'خصم ${product!.discountPercentage?.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Featured Badge
              if (product!.isFeatured)
                Positioned(
                  top: 100,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.secondaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'مميز',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product!.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (product!.brand != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product!.brand!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              if (product!.model != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'موديل: ${product!.model}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.price_change_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'السعر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                product!.formattedPrice,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              if (product!.hasDiscount) ...[
                Text(
                  product!.formattedOriginalPrice,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'وفر ${(product!.price - product!.displayPrice).toStringAsFixed(0)} ${product?.currencySymbol}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    if (product!.displayDescription.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.description_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'وصف المنتج',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product!.displayDescription,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsSection() {
    if (product!.specifications == null || product!.specifications!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'المواصفات والتفاصيل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Specifications List
          ...product!.specifications!.entries.map((entry) {
            final isLast = entry == product!.specifications!.entries.last;
            return Column(
              children: [
                _buildSpecificationItem(
                  icon: _getIconForSpecification(entry.key),
                  label: _formatSpecificationKey(entry.key),
                  value: entry.value.toString(),
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    height: 1,
                    thickness: 1,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpecificationItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon Container
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 14),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForSpecification(String key) {
    final keyLower = key.toLowerCase();

    // Display & Screen
    if (keyLower.contains('screen') ||
        keyLower.contains('display') ||
        keyLower.contains('شاشة') ||
        keyLower.contains('عرض')) {
      return Icons.monitor_rounded;
    }
    // Camera
    else if (keyLower.contains('camera') ||
        keyLower.contains('كاميرا') ||
        keyLower.contains('تصوير')) {
      return Icons.camera_alt_rounded;
    }
    // Battery & Power
    else if (keyLower.contains('battery') ||
        keyLower.contains('بطارية') ||
        keyLower.contains('طاقة') ||
        keyLower.contains('شحن')) {
      return Icons.battery_charging_full_rounded;
    }
    // Storage & Memory
    else if (keyLower.contains('storage') ||
        keyLower.contains('memory') ||
        keyLower.contains('rom') ||
        keyLower.contains('ذاكرة') ||
        keyLower.contains('تخزين')) {
      return Icons.sd_storage_rounded;
    } else if (
        keyLower.contains('ram') ||
        keyLower.contains('الرام') ||
        keyLower.contains('رام')
    )
    {
      return Icons.developer_board;
    }
    // Processor & CPU
    else if (keyLower.contains('processor') ||
        keyLower.contains('cpu') ||
        keyLower.contains('chipset') ||
        keyLower.contains('معالج')) {
      return Icons.memory_rounded;
    }
    // Weight
    else if (keyLower.contains('weight') || keyLower.contains('وزن')) {
      return Icons.fitness_center_rounded;
    }
    // Dimensions & Size
    else if (keyLower.contains('dimensions') ||
        keyLower.contains('size') ||
        keyLower.contains('height') ||
        keyLower.contains('width') ||
        keyLower.contains('thickness') ||
        keyLower.contains('أبعاد') ||
        keyLower.contains('حجم') ||
        keyLower.contains('سماكة')) {
      return Icons.straighten_rounded;
    }
    // Color
    else if (keyLower.contains('color') ||
        keyLower.contains('colour') ||
        keyLower.contains('اللون') ||
        keyLower.contains('الالوان')) {
      return Icons.palette_rounded;
    }
    // Warranty & Guarantee
    else if (keyLower.contains('warranty') ||
        keyLower.contains('guarantee') ||
        keyLower.contains('ضمان') ||
        keyLower.contains('كفالة')) {
      return Icons.verified_user_rounded;
    }
    // Operating System
    else if (keyLower.contains('os') ||
        keyLower.contains('operating system') ||
        keyLower.contains('android') ||
        keyLower.contains('ios') ||
        keyLower.contains('نظام') ||
        keyLower.contains('تشغيل')) {
      return Icons.phonelink_setup_rounded;
    }
    // Connectivity & Network
    else if (keyLower.contains('wifi') ||
        keyLower.contains('bluetooth') ||
        keyLower.contains('5g') ||
        keyLower.contains('4g') ||
        keyLower.contains('lte') ||
        keyLower.contains('network') ||
        keyLower.contains('connectivity') ||
        keyLower.contains('اتصال') ||
        keyLower.contains('شبكة')) {
      return Icons.wifi_rounded;
    }
    // Resolution
    else if (keyLower.contains('resolution') ||
        keyLower.contains('pixel') ||
        keyLower.contains('دقة') ||
        keyLower.contains('بكسل')) {
      return Icons.high_quality_rounded;
    }
    // Speed & Performance
    else if (keyLower.contains('speed') ||
        keyLower.contains('ghz') ||
        keyLower.contains('performance') ||
        keyLower.contains('سرعة') ||
        keyLower.contains('أداء')) {
      return Icons.speed_rounded;
    }
    // Ports & Connectivity
    else if (keyLower.contains('port') ||
        keyLower.contains('usb') ||
        keyLower.contains('hdmi') ||
        keyLower.contains('audio jack') ||
        keyLower.contains('منفذ')) {
      return Icons.usb_rounded;
    }
    // Material & Build
    else if (keyLower.contains('material') ||
        keyLower.contains('build') ||
        keyLower.contains('body') ||
        keyLower.contains('مادة') ||
        keyLower.contains('هيكل')) {
      return Icons.layers_rounded;
    }
    // Water Resistance
    else if (keyLower.contains('water') ||
        keyLower.contains('waterproof') ||
        keyLower.contains('ip rating') ||
        keyLower.contains('مقاوم') ||
        keyLower.contains('ماء')) {
      return Icons.water_drop_rounded;
    }
    // Sound & Audio
    else if (keyLower.contains('audio') ||
        keyLower.contains('sound') ||
        keyLower.contains('speaker') ||
        keyLower.contains('صوت') ||
        keyLower.contains('سماعة')) {
      return Icons.volume_up_rounded;
    }
    // Sensors
    else if (keyLower.contains('sensor') ||
        keyLower.contains('fingerprint') ||
        keyLower.contains('face') ||
        keyLower.contains('حساس') ||
        keyLower.contains('بصمة')) {
      return Icons.fingerprint_rounded;
    }
    // GPU & Graphics
    else if (keyLower.contains('gpu') ||
        keyLower.contains('graphics') ||
        keyLower.contains('الرسومات')) {
      return Icons.videogame_asset_rounded;
    }
    // Refresh Rate
    else if (keyLower.contains('refresh') ||
        keyLower.contains('hz') ||
        keyLower.contains('معدل') ||
        keyLower.contains('تحديث')) {
      return Icons.refresh_rounded;
    }
    // Brand
    else if (keyLower.contains('brand') ||
        keyLower.contains('manufacturer') ||
        keyLower.contains('علامة') ||
        keyLower.contains('صانع')) {
      return Icons.branding_watermark_rounded;
    }
    // Model
    else if (keyLower.contains('model') ||
        keyLower.contains('موديل') ||
        keyLower.contains('طراز')) {
      return Icons.category_rounded;
    }
    // Price
    else if (keyLower.contains('price') ||
        keyLower.contains('cost') ||
        keyLower.contains('سعر')) {
      return Icons.attach_money_rounded;
    }
    // Year & Release Date
    else if (keyLower.contains('year') ||
        keyLower.contains('date') ||
        keyLower.contains('release') ||
        keyLower.contains('سنة') ||
        keyLower.contains('تاريخ')) {
      return Icons.calendar_today_rounded;
    }
    // SIM Card
    else if (keyLower.contains('sim') ||
        keyLower.contains('dual') ||
        keyLower.contains('شريحة')) {
      return Icons.sim_card_rounded;
    }
    // NFC
    else if (keyLower.contains('nfc')) {
      return Icons.nfc_rounded;
    }
    // Charging
    else if (keyLower.contains('charging') ||
        keyLower.contains('fast charge') ||
        keyLower.contains('wireless') ||
        keyLower.contains('شاحن')) {
      return Icons.bolt_rounded;
    }
    // Capacity & Volume
    else if (keyLower.contains('capacity') ||
        keyLower.contains('volume') ||
        keyLower.contains('liter') ||
        keyLower.contains('سعة') ||
        keyLower.contains('حجم')) {
      return Icons.inventory_2_rounded;
    }
    // Temperature
    else if (keyLower.contains('temperature') ||
        keyLower.contains('cooling') ||
        keyLower.contains('heat') ||
        keyLower.contains('حرارة') ||
        keyLower.contains('تبريد')) {
      return Icons.thermostat_rounded;
    }
    // Power Consumption
    else if (keyLower.contains('power') ||
        keyLower.contains('watt') ||
        keyLower.contains('consumption') ||
        keyLower.contains('استهلاك')) {
      return Icons.power_rounded;
    }
    // Lens & Optics
    else if (keyLower.contains('lens') ||
        keyLower.contains('aperture') ||
        keyLower.contains('focal') ||
        keyLower.contains('عدسة')) {
      return Icons.lens_rounded;
    }
    // Video
    else if (keyLower.contains('video') ||
        keyLower.contains('recording') ||
        keyLower.contains('فيديو') ||
        keyLower.contains('تسجيل')) {
      return Icons.videocam_rounded;
    }
    // Flash
    else if (keyLower.contains('flash') ||
        keyLower.contains('led') ||
        keyLower.contains('فلاش')) {
      return Icons.flash_on_rounded;
    }
    // Zoom
    else if (keyLower.contains('zoom') || keyLower.contains('تقريب')) {
      return Icons.zoom_in_rounded;
    }
    // Keyboard
    else if (keyLower.contains('keyboard') ||
        keyLower.contains('keys') ||
        keyLower.contains('لوحة مفاتيح')) {
      return Icons.keyboard_rounded;
    }
    // Rating & Reviews
    else if (keyLower.contains('rating') ||
        keyLower.contains('review') ||
        keyLower.contains('star') ||
        keyLower.contains('تقييم')) {
      return Icons.star_rounded;
    }
    // Stock & Availability
    else if (keyLower.contains('stock') ||
        keyLower.contains('availability') ||
        keyLower.contains('available') ||
        keyLower.contains('متوفر') ||
        keyLower.contains('مخزون')) {
      return Icons.inventory_rounded;
    }
    // Origin & Country
    else if (keyLower.contains('origin') ||
        keyLower.contains('country') ||
        keyLower.contains('made in') ||
        keyLower.contains('منشأ') ||
        keyLower.contains('بلد')) {
      return Icons.public_rounded;
    }
    // Certification
    else if (keyLower.contains('certification') ||
        keyLower.contains('certified') ||
        keyLower.contains('شهادة')) {
      return Icons.verified_rounded;
    }
    // Default fallback icon
    else {
      return Icons.info_outline_rounded;
    }
  }

  String _formatSpecificationKey(String key) {
    return key;
  }

  Widget _buildStockInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: product!.inStock
            ? AppColors.success.withOpacity(0.05)
            : AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product!.inStock
              ? AppColors.success.withOpacity(0.2)
              : AppColors.error.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: product!.inStock
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              product!.inStock
                  ? Icons.inventory_rounded
                  : Icons.inventory_2_outlined,
              color: product!.inStock ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product!.inStock ? 'متوفر في المخزن' : 'غير متوفر حالياً',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: product!.inStock
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                if (product!.inStock) ...[
                  const SizedBox(height: 4),
                  Text(
                    product!.stockQuantity > 10
                        ? 'متوفر بكمية كبيرة'
                        : 'متبقي ${product!.stockQuantity} قطع فقط',
                    style: TextStyle(
                      fontSize: 12,
                      color: product!.stockQuantity > 10
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (product!.inStock && product!.stockQuantity <= 5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'كمية محدودة',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.recommend_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'منتجات مشابهة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoadingSimilar)
            _buildSimilarProductsLoading()
          else if (similarProductsError.isNotEmpty)
            _buildSimilarProductsError()
          else if (similarProducts.isEmpty)
            _buildNoSimilarProducts()
          else
            _buildSimilarProductsList(),
        ],
      ),
    );
  }

  Widget _buildSimilarProductsLoading() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 170,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: LoadingWidget(size: 30, message: "جاري التحميل..."),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimilarProductsError() {
    return ShamraCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            similarProductsError,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ShamraButton(
            text: 'إعادة المحاولة',
            onPressed: _loadSimilarProducts,
            isOutlined: true,
            width: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSimilarProducts() {
    return ShamraCard(
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.grey),
          SizedBox(height: 12),
          Text(
            'لا توجد منتجات مشابهة متاحة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'ربما تجد ما تبحث عنه في قسم المنتجات',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProductsList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.info, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تم اختيار هذه المنتجات بناءً على الفئة، السعر، والعلامة التجارية',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: similarProducts.length,
            itemBuilder: (context, index) {
              final similarProduct = similarProducts[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(left: 12),
                child: ProductCard(
                  product: similarProduct,
                  onTap: () => Get.offAndToNamed(
                    '/product-details',
                    arguments: similarProduct.id,
                  ),
                  matchPercent: _calculateSimilarityScore(similarProduct),
                  matchThreshold: 60,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Bottom bar — with quantity controls if already in cart
  Widget _buildBottomBar() {
    return Obx(() {
      final cartController = Get.find<CartController>();
      final isInCart = cartController.isInCart(product!.id);
      final quantity = cartController.getProductQuantity(product!.id);

      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              if (isInCart)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            cartController.decrementQuantity(product!.id),
                        icon: const Icon(
                          Icons.remove_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(
                        width: 27,
                        child: Text(
                          quantity.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            cartController.incrementQuantity(product!.id),
                        icon: const Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: ShamraButton(
                  text: isInCart ? 'تمت إضافته للسلة' : 'إضافة للسلة',
                  onPressed: product!.inStock
                      ? () => cartController.addToCart(product!)
                      : () {
                          ShamraSnackBar.show(
                            context: Get.context!,
                            message:
                                'المنتج ${product!.name} غير متوفر حاليًا.',
                            type: SnackBarType.error,
                          );
                        },
                  isOutlined: !product!.inStock,
                  icon: Icons.add_shopping_cart_rounded,
                  height: 56,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
