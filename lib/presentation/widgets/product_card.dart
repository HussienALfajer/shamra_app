import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/product.dart';
import '../../core/constants/colors.dart';
import '../../data/utils/helpers.dart';
import '../controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showAddToCart;
  final double? width;
  final double? height;
  final bool isGridView;

  final int? matchPercent;
  final int matchThreshold;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.showAddToCart = true,
    this.width,
    this.height,
    this.isGridView = false,
    this.matchPercent,
    this.matchThreshold = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartController) {
        return Container(
          // جعل العرض ديناميكي مع حد أدنى وأقصى
          width: width ?? (isGridView ? null : 160),
          constraints: BoxConstraints(
            minWidth: 140,
            maxWidth: isGridView ? double.infinity : 200,
            minHeight: 200, // حد أدنى للارتفاع
          ),
          margin: const EdgeInsets.only(left: 12, bottom: 12),
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            elevation: 3,
            shadowColor: AppColors.shadowColor.withOpacity(0.08),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // مهم جداً لجعل Column ديناميكي
                children: [
                  // 🔹 صورة المنتج - ارتفاع ثابت
                  Container(
                    width: double.infinity,
                    height: 150, // ارتفاع ثابت للصورة
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: HelperMethod.getImageUrl(
                              product.mainImage,
                            ),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.lightGrey.withOpacity(0.3),
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.grey,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // شارة الخصم
                        if (product.hasDiscount)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.red, Colors.red.shade700],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_offer_rounded,
                                    color: AppColors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'خصم ${product.discountPercentage?.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // شارة المميز (تظهر بدلاً من شارة الخصم إذا لم يكن هناك خصم)
                        if (product.isFeatured)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.secondaryGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    color: AppColors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'مميز',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (matchPercent != null && matchPercent! >= matchThreshold)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.verified, size: 10, color: AppColors.white),
                                  const SizedBox(width: 2),
                                  Text(
                                    'مطابق ${matchPercent}%',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            product.displayName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),
                          Wrap(
                            children: [
                              Text(
                                product.formattedPrice,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),

                              if (product.hasDiscount) ...[
                                const SizedBox(width: 6),
                                Text(
                                  product.formattedOriginalPrice,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.red,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: AppColors.red,
                                  ),
                                ),
                              ],
                            ],
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
      },
    );
  }
}
