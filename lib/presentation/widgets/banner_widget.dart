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
  late final PageController pageController;
  late final BannerController bannerController;
  Timer? autoPlayTimer;
  final RxInt currentIndex = 0.obs; // normalized index [0 .. len-1]

  @override
  void initState() {
    super.initState();
    // initialPage can be 0; we will go infinite via modulo indexing
    pageController = PageController(viewportFraction: 0.9);
    bannerController = Get.find<BannerController>();

    if (widget.autoPlay) _startAutoPlay();
  }

  @override
  void dispose() {
    autoPlayTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    autoPlayTimer?.cancel();
    autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      final banners = _uniqueById(bannerController.activeBanners);
      if (banners.length <= 1) return;
      if (!pageController.hasClients) return;

      // Move to the next (infinite) page; we'll normalize with modulo in builder/onPageChanged
      final next = (pageController.page?.round() ?? 0) + 1;
      pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoPlay() => autoPlayTimer?.cancel();

  // Ensure unique banners by id (defensive against dup data sources)
  List<BannerModel.Banner> _uniqueById(List<BannerModel.Banner> list) {
    final seen = <String>{};
    return list.where((b) => seen.add(b.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Use Obx directly against the same controller instance
    return Obx(() {
      final isLoading = bannerController.isLoading;
      final hasError = bannerController.errorMessage.isNotEmpty;
      final raw = bannerController.activeBanners;
      final banners = _uniqueById(raw);

      // Loading
      if (isLoading && raw.isEmpty) return _buildShimmerBanner();

      // Error
      if (hasError && raw.isEmpty) return _buildErrorBanner(bannerController);

      // Empty
      if (banners.isEmpty) return const SizedBox.shrink();

      // Make sure autoplay is (re)started when needed
      if (widget.autoPlay && (autoPlayTimer == null || !autoPlayTimer!.isActive)) {
        _startAutoPlay();
      }

      return _buildBannerCarousel(banners);
    });
  }

  Widget _buildBannerCarousel(List<BannerModel.Banner> banners) {
    if (banners.length == 1) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: _BannerCard(
          banner: banners.first,
          height: widget.height,
          onTap: () => bannerController.onBannerTap(banners.first),
        ),
      );
    }

    // Infinite scroll with modulo indexing (no itemCount)
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (rawIndex) {
              // Normalize to [0..len-1]
              currentIndex.value = rawIndex % banners.length;
            },
            itemBuilder: (context, rawIndex) {
              final index = rawIndex % banners.length;
              final banner = banners[index];
              return Container(
                margin: const EdgeInsets.only(bottom:5,left: 8,right: 8),
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
            final raw = pageController.page?.round() ?? 0;
            // jump within the current "block" of [0..count-1]
            final base = raw - (raw % count);
            pageController.animateToPage(
              base + index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            if (widget.autoPlay) _startAutoPlay();
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
      child: const Center(child: LoadingWidget(size: 30)),
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
            Icon(Icons.error_outline, color: AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(
              'فشل تحميل البانرات',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
          child: CachedNetworkImage(
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
          ),
        ),
      ),
    );
  }
}
