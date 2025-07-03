import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolvystore/controllers/product_controller.dart';
import 'package:wolvystore/models/product_model.dart';
import 'package:wolvystore/view/product_detail_screen.dart';

class ProductGrid extends StatefulWidget {
  final Product data;

  const ProductGrid({super.key, required this.data});

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  bool _imageLoaded = false;

  void markImageLoaded() {
    if (!_imageLoaded && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _imageLoaded = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final imageUrl = widget.data.fotoProduk;
    final productController = Get.find<ProductController>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Get.to(() => ProductDetailScreen(product: widget.data));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null && imageUrl.isNotEmpty)
                        AnimatedOpacity(
                          opacity: _imageLoaded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                markImageLoaded();
                                return child;
                              } else {
                                return const SizedBox();
                              }
                            },
                            errorBuilder:
                                (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                          ),
                        )
                      else
                        Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      if (!_imageLoaded)
                        const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      // Favorite icon
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Obx(() {
                          final isFavorite = productController.favoriteIds
                              .contains(widget.data.id.toString());
                          return GestureDetector(
                            onTap: () {
                              productController.toggleFavorite(
                                widget.data.id.toString(),
                              );
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.namaProduk,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${widget.data.harga}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.orange[300] : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
