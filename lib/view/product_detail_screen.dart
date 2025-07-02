import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolvystore/controllers/product_controller.dart';
import 'package:wolvystore/controllers/cart_controller.dart';
import 'package:wolvystore/models/product_model.dart';
import 'package:wolvystore/view/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final productController = Get.find<ProductController>();
  final cartController = Get.find<CartController>();
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final inputColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFA6E3E9);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);

    final product = widget.product;

    final categoryLabel =
        productController.categories.firstWhereOrNull(
          (cat) => cat['id'] == product.kategori,
        )?['label'] ??
        'Tidak diketahui';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          ClipPath(
            clipper: BottomCurveClipper(),
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
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.shopping_bag, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Detail Produk',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        product.fotoProduk != null &&
                                product.fotoProduk!.isNotEmpty
                            ? FadeInImage.assetNetwork(
                              placeholder: 'assets/images/placeholder.png',
                              image: product.fotoProduk!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 250,
                              color: inputColor,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    product.namaProduk,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Rp ${product.harga}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(Icons.category, size: 20, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        'Kategori: $categoryLabel',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: theme.hintColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Stok: ${product.stok}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Deskripsi:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.deskripsi ?? 'Tidak ada deskripsi.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Jumlah:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.dividerColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed:
                              quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                        ),
                        Text(
                          '$quantity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed:
                              quantity < product.stok
                                  ? () => setState(() => quantity++)
                                  : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: inputColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Masukkan Keranjang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  cartController.addToCart(product, quantity);
                  Get.snackbar(
                    'Berhasil',
                    'Produk ditambahkan ke keranjang',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.flash_on),
                label: const Text('Beli Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  cartController.addToCart(product, quantity);
                  Get.to(() => CartScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
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
