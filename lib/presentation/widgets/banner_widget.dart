import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../data/utils/helpers.dart';
import '../../../data/models/banner.dart' as BannerModel;
import '../controllers/banner_controller.dart';
import 'common_widgets.dart';

class BannerCarousel extends StatefulWidget {
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showDots;

  const BannerCarousel({
    super.key,
    this.height = 200,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.showDots = true,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController pageController;
  late BannerController bannerController;
  Timer? autoPlayTimer;
  final RxInt currentIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: 0.9);
    bannerController = Get.find<BannerController>();

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    autoPlayTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    autoPlayTimer?.cancel();
    autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (bannerController.activeBanners.isNotEmpty && pageController.hasClients) {
        final nextPage = (currentIndex.value + 1) % bannerController.activeBanners.length;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopAutoPlay() {
    autoPlayTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(
      builder: (controller) {
        return Obx(() {
          // Loading state
          if (controller.isLoading && controller.banners.isEmpty) {
            return _buildShimmerBanner();
          }

          // Error state
          if (controller.errorMessage.isNotEmpty && controller.banners.isEmpty) {
            return _buildErrorBanner(controller);
          }

          // Empty state
          if (controller.activeBanners.isEmpty) {
            return const SizedBox.shrink();
          }

          // Update auto-play when banners change
          if (widget.autoPlay && !autoPlayTimer!.isActive) {
            _startAutoPlay();
          }

          // Banner carousel
          return _buildBannerCarousel(controller.activeBanners);
        });
      },
    );
  }

  Widget _buildBannerCarousel(List<BannerModel.Banner> banners) {
    if (banners.length == 1) {
      // Single banner
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: _BannerCard(
          banner: banners.first,
          height: widget.height,
          onTap: () => bannerController.onBannerTap(banners.first),
        ),
      );
    }

    // Multiple banners carousel
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              currentIndex.value = index;
            },
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _BannerCard(
                  banner: banner,
                  height: widget.height,
                  onTap: () => bannerController.onBannerTap(banner),
                ),
              );
            },
          ),
        ),

        if (widget.showDots && banners.length > 1) ...[
          const SizedBox(height: 12),
          _buildDots(banners.length),
        ],
      ],
    );
  }

  Widget _buildDots(int count) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
            (index) => GestureDetector(
          onTap: () {
            _stopAutoPlay();
            pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            if (widget.autoPlay) {
              _startAutoPlay();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: currentIndex.value == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: currentIndex.value == index
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildShimmerBanner() {
    return Container(
      height: widget.height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: LoadingWidget(size: 30),
      ),
    );
  }

  Widget _buildErrorBanner(BannerController controller) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'فشل تحميل البانرات',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerModel.Banner banner;
  final double height;
  final VoidCallback onTap;

  const _BannerCard({
    required this.banner,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Banner image
              _buildBannerImage(),

              // Overlay gradient
              // _buildOverlayGradient(),
              //
              // // Banner content
              // if (banner.hasProduct || banner.hasCategory)
              //   _buildBannerContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    return CachedNetworkImage(
      imageUrl: HelperMethod.getImageUrl(banner.displayImage),
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColors.lightGrey.withOpacity(0.3),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withOpacity(0.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColors.primary.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: AppColors.primary.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'فشل تحميل الصورة',
              style: TextStyle(
                color: AppColors.primary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayGradient() {
    if (!banner.hasProduct && !banner.hasCategory) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerContent() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (banner.hasProduct && banner.product != null) ...[
            Text(
              banner.product!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${banner.product!.price.toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ] else if (banner.hasCategory && banner.category != null) ...[
            Text(
              banner.category!.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'تصفح الفئة',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}