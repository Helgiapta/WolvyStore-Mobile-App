import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolvystore/controllers/cart_controller.dart';
import 'package:wolvystore/controllers/product_controller.dart';
import 'package:wolvystore/view/checkout_screen.dart';
import 'package:wolvystore/view/home_wrapper.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final cartController = Get.find<CartController>();
  final productController = Get.find<ProductController>();

  Future<String?> getAlamatUser() async {
    final uid = productController.supabase.auth.currentUser?.id;
    if (uid == null) return null;

    final data =
        await productController.supabase
            .from('user_acc')
            .select('alamat_kirim')
            .eq('uid', uid)
            .maybeSingle();

    return data?['alamat_kirim'];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final cardColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFCBF1F5);
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
                  Text(
                    'Keranjang',
                    style: const TextStyle(
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
              final items = cartController.items;
              final allProductIds =
                  items.map((e) => e.product.id.toString()).toList();
              final isAllSelected =
                  allProductIds.isNotEmpty &&
                  allProductIds.every(
                    (id) => cartController.selectedItemIds.contains(id),
                  );

              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'Keranjang kosong.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: isAllSelected,
                          onChanged: (_) {
                            cartController.toggleSelectAll(
                              allProductIds,
                              isAllSelected,
                            );
                          },
                        ),
                        Text(
                          'Pilih Semua',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final product = item.product;
                        final isSelected = cartController.selectedItemIds
                            .contains(product.id.toString());

                        return Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (_) {
                                  cartController.toggleSelection(
                                    product.id.toString(),
                                  );
                                },
                              ),
                              if (product.fotoProduk != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product.fotoProduk!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else
                                const Icon(Icons.image_not_supported, size: 60),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.namaProduk,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${product.harga}',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed:
                                              item.quantity > 1
                                                  ? () => cartController
                                                      .decreaseQuantity(
                                                        product.id.toString(),
                                                      )
                                                  : null,
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: TextStyle(
                                            color:
                                                isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed:
                                              item.quantity < product.stok
                                                  ? () => cartController
                                                      .increaseQuantity(
                                                        product.id.toString(),
                                                      )
                                                  : null,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed:
                                    () => cartController.removeFromCart(
                                      product.id.toString(),
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
          Obx(() {
            final selectedItems =
                cartController.items
                    .where(
                      (item) => cartController.selectedItemIds.contains(
                        item.product.id.toString(),
                      ),
                    )
                    .toList();
            final total = cartController.totalSelectedPrice;

            final isDisabled = cartController.selectedItemIds.isEmpty;

            return Container(
              padding: const EdgeInsets.all(16),
              color: accentColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: Rp $total',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDisabled ? Colors.white70 : Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDisabled ? Colors.white54 : Colors.white,
                      foregroundColor:
                          isDisabled ? Colors.grey[600] : accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed:
                        isDisabled
                            ? null
                            : () async {
                              final alamat = await getAlamatUser();
                              if (alamat == null || alamat.trim().isEmpty) {
                                Get.defaultDialog(
                                  title: 'Alamat Kosong',
                                  middleText:
                                      'Silakan isi alamat pengiriman terlebih dahulu di menu profil.',
                                  textConfirm: 'OK',
                                  onConfirm: () => Get.back(),
                                );
                                return;
                              }
                              Get.to(
                                () => CheckoutScreen(
                                  items: selectedItems,
                                  total: total,
                                ),
                              );
                            },
                    child: const Text('Checkout'),
                  ),
                ],
              ),
            );
          }),
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
