import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:shamra_app/data/utils/helpers.dart';
import '../../data/models/product.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';
import '../controllers/cart_controller.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:
            onTap ?? () => Get.toNamed('/product-details', arguments: product),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: product.mainImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: HelperMethod.getImageUrl(product.mainImage),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.lightGrey,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.lightGrey,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.grey,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.lightGrey,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.grey,
                            size: 40,
                          ),
                        ),
                ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Brand
                    if (product.brand != null)
                      Text(
                        product.brand!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Price and Add to Cart
                    Row(
                      children: [
                        // Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.hasDiscount) ...[
                                Text(
                                  '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  '${AppConstants.currency} ${product.displayPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ] else
                                Text(
                                  '${AppConstants.currency} ${product.displayPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Add to Cart Button
                        if (showAddToCart && product.inStock)
                          Obx(() {
                            final isInCart = cartController.isInCart(
                              product.id,
                            );
                            return InkWell(
                              onTap: () {
                                if (isInCart) {
                                  cartController.removeFromCart(product.id);
                                } else {
                                  cartController.addToCart(product);
                                }
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isInCart
                                      ? AppColors.secondary
                                      : AppColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  isInCart
                                      ? Icons.remove_shopping_cart
                                      : Icons.add_shopping_cart,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            );
                          }),
                      ],
                    ),

                    // Stock Status
                    if (!product.inStock)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
