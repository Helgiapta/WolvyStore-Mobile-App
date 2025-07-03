import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:wolvystore/view/home_wrapper.dart';

class ConfirmationOrderScreen extends StatelessWidget {
  const ConfirmationOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments ?? {};
    final int totalItems = args['totalItems'] ?? 0;
    final String deliveryMethod = args['deliveryMethod'] ?? 'reguler';

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);
    final textColor = isDark ? Colors.white : Colors.black;

    String estimatedDelivery;
    switch (deliveryMethod) {
      case 'kargo':
        estimatedDelivery = '3–7 hari kerja';
        break;
      case 'instan':
        estimatedDelivery = 'dalam 24 jam';
        break;
      default:
        estimatedDelivery = '1–3 hari kerja';
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/order_success.json',
                  width: 200,
                  repeat: false,
                ),
                const SizedBox(height: 32),
                Text(
                  'Pesanan Berhasil!',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total Barang: $totalItems\nEstimasi Pengantaran: $estimatedDelivery',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: textColor),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => const HomeWrapper(initialIndex: 0));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
