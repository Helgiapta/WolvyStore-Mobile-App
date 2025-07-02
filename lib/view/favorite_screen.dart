import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolvystore/controllers/product_controller.dart';
import 'package:wolvystore/view/widgets/product_grid.dart';
import 'package:wolvystore/view/home_wrapper.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productController = Get.find<ProductController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              width: double.infinity,
              color: accentColor,
              padding: const EdgeInsets.only(
                top: 48,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.offAll(() => const HomeWrapper()),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Produk Favorit',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final favorites = productController.favoriteProducts;

              if (favorites.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada produk favorit.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                  itemCount: favorites.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (_, index) {
                    final product = favorites[index];
                    return Stack(
                      children: [
                        ProductGrid(data: product),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              productController.toggleFavorite(product.id);
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
