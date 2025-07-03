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
    // Tentukan apakah tema saat ini gelap berdasarkan kecerahan
    final isDark = theme.brightness == Brightness.dark;

    // Warna kustom berdasarkan tema yang Anda berikan
    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final cardColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFCBF1F5);
    final inputColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFA6E3E9);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);
    final textColor =
        isDark
            ? Colors.white
            : Colors.black; // Sesuaikan warna teks untuk keterbacaan

    return Scaffold(
      backgroundColor: backgroundColor, // Terapkan warna latar belakang kustom
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
                    color: accentColor, // Terapkan warna aksen kustom
                    padding: const EdgeInsets.only(
                      top: 48,
                      bottom: 24,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: textColor, // Sesuaikan warna ikon
                          ),
                          onPressed: () => Get.back(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor, // Sesuaikan warna teks
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
                                  color:
                                      cardColor, // Terapkan warna kartu kustom
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 28,
                                      color: textColor,
                                    ), // Sesuaikan warna ikon
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Alamat Pengiriman',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      textColor, // Sesuaikan warna teks
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            alamatUser,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      textColor, // Sesuaikan warna teks
                                                ),
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
                                          color:
                                              cardColor, // Terapkan warna kartu kustom
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
                                                    style: theme
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              textColor, // Sesuaikan warna teks
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Rp ${NumberFormat("#,###").format(product.harga)} x ${item.quantity}',
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              textColor, // Sesuaikan warna teks
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Rp ${NumberFormat("#,###").format(product.harga * item.quantity)}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        textColor, // Sesuaikan warna teks
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Sesuaikan warna teks
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: [
                                  buildDeliveryOption(
                                    'Reguler',
                                    15000,
                                    'reguler',
                                    textColor,
                                  ),
                                  buildDeliveryOption(
                                    'Kargo',
                                    10000,
                                    'kargo',
                                    textColor,
                                  ),
                                  buildDeliveryOption(
                                    'Instan',
                                    20000,
                                    'instan',
                                    textColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Metode Pembayaran:',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Sesuaikan warna teks
                                ),
                              ),
                              const SizedBox(height: 8),
                              buildPaymentOptions(
                                inputColor,
                                textColor,
                              ), // Teruskan warna input dan teks
                              const Divider(height: 32),
                              Text(
                                'Rincian Pembayaran:',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor, // Sesuaikan warna teks
                                ),
                              ),
                              buildPriceRow(
                                'Subtotal Pesanan',
                                widget.total,
                                textColor,
                              ),
                              buildPriceRow(
                                'Subtotal Pengiriman',
                                deliveryCost,
                                textColor,
                              ),
                              if (hasDiscount)
                                buildPriceRow(
                                  'Potongan Harga',
                                  -discountAmount,
                                  textColor,
                                ),
                              buildPriceRow(
                                'Total Pembayaran',
                                grandTotal,
                                bold: true,
                                textColor,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                      // Perbaikan: Teruskan backgroundColor langsung, bukan objek ThemeData
                      buildBottomBar(
                        backgroundColor,
                        grandTotal,
                        accentColor,
                        textColor,
                      ),
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

  Widget buildDeliveryOption(
    String label,
    int cost,
    String value,
    Color textColor,
  ) {
    return RadioListTile(
      title: Text(
        '$label (Rp ${NumberFormat("#,###").format(cost)})',
        style: TextStyle(color: textColor),
      ), // Sesuaikan warna teks
      value: value,
      groupValue: selectedDelivery.value,
      onChanged: (val) => selectedDelivery.value = val!,
      activeColor:
          Theme.of(context)
              .colorScheme
              .primary, // Pertahankan warna aktif asli untuk tombol radio
    );
  }

  Widget buildPriceRow(
    String label,
    int amount,
    Color textColor, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: textColor),
          ), // Sesuaikan warna teks
          Text(
            (amount < 0 ? '- ' : '') +
                'Rp ${NumberFormat("#,###").format(amount.abs())}',
            style:
                bold
                    ? TextStyle(fontWeight: FontWeight.bold, color: textColor)
                    : TextStyle(color: textColor), // Sesuaikan warna teks
          ),
        ],
      ),
    );
  }

  Widget buildPaymentOptions(Color inputColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile(
          title: Text(
            'Kartu Kredit / Debit',
            style: TextStyle(color: textColor),
          ), // Sesuaikan warna teks
          value: 'kartu',
          groupValue: paymentMethod.value,
          onChanged: (val) => paymentMethod.value = val!,
          activeColor:
              Theme.of(
                context,
              ).colorScheme.primary, // Pertahankan warna aktif asli
        ),
        if (paymentMethod.value == 'kartu')
          Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedBank.value.isEmpty ? null : selectedBank.value,
                hint: Text(
                  'Pilih Bank',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ), // Sesuaikan warna teks petunjuk
                dropdownColor:
                    inputColor, // Terapkan warna input kustom ke latar belakang dropdown
                style: TextStyle(
                  color: textColor,
                ), // Sesuaikan warna teks item dropdown
                items:
                    ['BRI', 'BNI', 'Mandiri', 'BCA']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: TextStyle(color: textColor)),
                          ),
                        ) // Sesuaikan warna teks item dropdown
                        .toList(),
                onChanged: (val) => selectedBank.value = val ?? '',
                decoration: InputDecoration(
                  fillColor: inputColor, // Terapkan warna input kustom
                  filled: true,
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: textColor,
                  ), // Sesuaikan warna teks label
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Nomor Kartu',
                  border: const OutlineInputBorder(),
                  fillColor: inputColor, // Terapkan warna input kustom
                  filled: true,
                  labelStyle: TextStyle(
                    color: textColor,
                  ), // Sesuaikan warna teks label
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: textColor,
                ), // Sesuaikan warna teks input
              ),
            ],
          ),
        RadioListTile(
          title: Text(
            'Dompet Digital',
            style: TextStyle(color: textColor),
          ), // Sesuaikan warna teks
          value: 'e-wallet',
          groupValue: paymentMethod.value,
          onChanged: (val) => paymentMethod.value = val!,
          activeColor:
              Theme.of(
                context,
              ).colorScheme.primary, // Pertahankan warna aktif asli
        ),
        if (paymentMethod.value == 'e-wallet')
          Column(
            children: [
              DropdownButtonFormField<String>(
                value:
                    selectedEwallet.value.isEmpty
                        ? null
                        : selectedEwallet.value,
                hint: Text(
                  'Pilih Dompet Digital',
                  style: TextStyle(color: textColor.withOpacity(0.7)),
                ), // Sesuaikan warna teks petunjuk
                dropdownColor:
                    inputColor, // Terapkan warna input kustom ke latar belakang dropdown
                style: TextStyle(
                  color: textColor,
                ), // Sesuaikan warna teks item dropdown
                items:
                    ['Dana', 'Gopay', 'ShopeePay', 'OVO']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: TextStyle(color: textColor)),
                          ),
                        ) // Sesuaikan warna teks item dropdown
                        .toList(),
                onChanged: (val) => selectedEwallet.value = val ?? '',
                decoration: InputDecoration(
                  fillColor: inputColor, // Terapkan warna input kustom
                  filled: true,
                  border: const OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: textColor,
                  ), // Sesuaikan warna teks label
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Nomor HP',
                  border: const OutlineInputBorder(),
                  fillColor: inputColor, // Terapkan warna input kustom
                  filled: true,
                  labelStyle: TextStyle(
                    color: textColor,
                  ), // Sesuaikan warna teks label
                ),
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: textColor,
                ), // Sesuaikan warna teks input
              ),
            ],
          ),
      ],
    );
  }

  Widget buildBottomBar(
    Color bottomBarBackgroundColor,
    int total,
    Color accentColor,
    Color textColor,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bottomBarBackgroundColor, // Gunakan parameter yang diperbaiki
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor, // Sesuaikan warna teks
                  ),
                ),
                if (hasDiscount)
                  Text(
                    'Hemat Rp ${NumberFormat("#,###").format(discountAmount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ), // Pertahankan hijau untuk diskon
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: handleCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    accentColor, // Terapkan warna aksen kustom ke tombol
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Bayar Sekarang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor, // Sesuaikan warna teks untuk tombol
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
