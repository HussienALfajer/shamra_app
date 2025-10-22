import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullscreenImageViewer extends StatefulWidget {
  final List<dynamic> images;       // MUST be absolute URLs
  final int initialIndex;
  final String? heroPrefix;        // e.g. 'product-<id>-img-'

  const FullscreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroPrefix,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen black canvas
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable, swipeable gallery
          PhotoViewGallery.builder(
            pageController: _pageController,
            itemCount: widget.images.length,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            gaplessPlayback: true,
            onPageChanged: (i) => setState(() => _index = i),
            builder: (ctx, i) {
              final url = widget.images[i];
              return PhotoViewGalleryPageOptions(
                // Use CachedNetworkImageProvider for caching
                imageProvider: CachedNetworkImageProvider(url),
                heroAttributes: widget.heroPrefix == null
                    ? null
                    : PhotoViewHeroAttributes(tag: '${widget.heroPrefix}$i'),
                minScale: PhotoViewComputedScale.contained,     // Fit screen
                initialScale: PhotoViewComputedScale.contained, // Start fitted
                maxScale: PhotoViewComputedScale.covered * 3.5, // Zoom factor
              );
            },
            // Optional: show a tiny loader while image resolves
            loadingBuilder: (_, __) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),

          // Close button (top-left, RTL-friendly enough for fullscreen)
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
                tooltip: 'إغلاق', // Arabic label for accessibility
              ),
            ),
          ),

          // Page indicator (bottom-center)
          if (widget.images.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_index + 1}/${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
