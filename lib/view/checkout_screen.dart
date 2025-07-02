import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wolvystore/controllers/product_controller.dart';
import 'package:wolvystore/controllers/cart_controller.dart';
import 'package:wolvystore/models/cartitem_model.dart';
import 'package:wolvystore/view/confirmation_order_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> items;
  final int total;

  const CheckoutScreen({super.key, required this.items, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final productController = Get.find<ProductController>();
  final paymentMethod = ''.obs;
  final selectedBank = ''.obs;
  final selectedEwallet = ''.obs;
  final selectedDelivery = 'reguler'.obs;

  final cardNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();

  final bool hasDiscount = Random().nextBool();
  late final int discountAmount;

  late Future<String> alamatFuture;

  @override
  void initState() {
    super.initState();
    discountAmount = hasDiscount ? (widget.total * 0.1).round() : 0;

    final user = productController.supabase.auth.currentUser;
    alamatFuture =
        user != null
            ? productController.supabase
                .from('user_acc')
                .select('alamat_kirim')
                .eq('uid', user.id)
                .maybeSingle()
                .then(
                  (value) => value?['alamat_kirim'] ?? 'Alamat belum tersedia',
                )
            : Future.value('Alamat belum tersedia');
  }

  int get deliveryCost {
    switch (selectedDelivery.value) {
      case 'kargo':
        return 10000;
      case 'instan':
        return 20000;
      default:
        return 15000;
    }
  }

  int get grandTotal => widget.total - discountAmount + deliveryCost;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<String>(
        future: alamatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final alamatUser = snapshot.data ?? 'Alamat belum tersedia';

          return Obx(
            () => Column(
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Checkout',
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
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Alamat Pengiriman',
                                            style: textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            alamatUser,
                                            style: textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children:
                                    widget.items.map((item) {
                                      final product = item.product;
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                product.fotoProduk ?? '',
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.namaProduk,
                                                    style: textTheme.bodyLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Rp ${NumberFormat("#,###").format(product.harga)} x ${item.quantity}',
                                                    style: textTheme.bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Rp ${NumberFormat("#,###").format(product.harga * item.quantity)}',
                                              style: textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Opsi Pengiriman:',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  buildDeliveryOption(
                                    'Reguler',
                                    15000,
                                    'reguler',
                                  ),
                                  buildDeliveryOption('Kargo', 10000, 'kargo'),
                                  buildDeliveryOption(
                                    'Instan',
                                    20000,
                                    'instan',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Metode Pembayaran:',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              buildPaymentOptions(),
                              const Divider(height: 32),
                              Text(
                                'Rincian Pembayaran:',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              buildPriceRow('Subtotal Pesanan', widget.total),
                              buildPriceRow(
                                'Subtotal Pengiriman',
                                deliveryCost,
                              ),
                              if (hasDiscount)
                                buildPriceRow(
                                  'Potongan Harga',
                                  -discountAmount,
                                ),
                              buildPriceRow(
                                'Total Pembayaran',
                                grandTotal,
                                bold: true,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                      buildBottomBar(theme, grandTotal),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildDeliveryOption(String label, int cost, String value) {
    return RadioListTile(
      title: Text('$label (Rp ${NumberFormat("#,###").format(cost)})'),
      value: value,
      groupValue: selectedDelivery.value,
      onChanged: (val) => selectedDelivery.value = val!,
    );
  }

  Widget buildPriceRow(String label, int amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            (amount < 0 ? '- ' : '') +
                'Rp ${NumberFormat("#,###").format(amount.abs())}',
            style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null,
          ),
        ],
      ),
    );
  }

  Widget buildPaymentOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          title: const Text('Kartu Kredit / Debit'),
          value: 'kartu',
          groupValue: paymentMethod.value,
          onChanged: (val) => paymentMethod.value = val!,
        ),
        if (paymentMethod.value == 'kartu')
          Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedBank.value.isEmpty ? null : selectedBank.value,
                hint: const Text('Pilih Bank'),
                items:
                    ['BRI', 'BNI', 'Mandiri', 'BCA']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => selectedBank.value = val ?? '',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kartu',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        RadioListTile(
          title: const Text('Dompet Digital'),
          value: 'e-wallet',
          groupValue: paymentMethod.value,
          onChanged: (val) => paymentMethod.value = val!,
        ),
        if (paymentMethod.value == 'e-wallet')
          Column(
            children: [
              DropdownButtonFormField<String>(
                value:
                    selectedEwallet.value.isEmpty
                        ? null
                        : selectedEwallet.value,
                hint: const Text('Pilih Dompet Digital'),
                items:
                    ['Dana', 'Gopay', 'ShopeePay', 'OVO']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => selectedEwallet.value = val ?? '',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor HP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
      ],
    );
  }

  Widget buildBottomBar(ThemeData theme, int total) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: Rp ${NumberFormat("#,###").format(total)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasDiscount)
                  Text(
                    'Hemat Rp ${NumberFormat("#,###").format(discountAmount)}',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleCheckout() {
    if (paymentMethod.value == 'kartu') {
      if (selectedBank.value.isEmpty || cardNumberController.text.isEmpty) {
        Get.snackbar('Peringatan', 'Isi informasi kartu terlebih dahulu');
        return;
      }
    } else if (paymentMethod.value == 'e-wallet') {
      if (selectedEwallet.value.isEmpty || phoneNumberController.text.isEmpty) {
        Get.snackbar(
          'Peringatan',
          'Isi informasi dompet digital terlebih dahulu',
        );
        return;
      }
    } else {
      Get.snackbar('Peringatan', 'Pilih metode pembayaran terlebih dahulu');
      return;
    }

    final totalItems = widget.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final cartController = Get.find<CartController>();
    for (var item in widget.items) {
      cartController.removeFromCart(item.product.id.toString());
    }

    Get.off(
      () => const ConfirmationOrderScreen(),
      arguments: {
        'totalItems': totalItems,
        'deliveryMethod': selectedDelivery.value,
      },
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
