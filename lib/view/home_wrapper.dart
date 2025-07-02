import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wolvystore/controllers/product_controller.dart';
import 'package:wolvystore/view/main_screen.dart';
import 'package:wolvystore/view/favorite_screen.dart';
import 'package:wolvystore/view/profile_screen.dart';
import 'package:wolvystore/view/cart_screen.dart';
import 'package:wolvystore/view/login_screen.dart';

class HomeWrapper extends StatefulWidget {
  final int initialIndex;

  const HomeWrapper({super.key, this.initialIndex = 0});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  late int _selectedIndex;

  final screens = [
    MainScreen(),
    const FavoriteScreen(),
    CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      Future.microtask(() {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      });
    }

    if (!Get.isRegistered<ProductController>()) {
      Get.put(ProductController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Gunakan warna primer dan teks aktif yang kontras
    final backgroundColor = theme.scaffoldBackgroundColor;
    final activeIconColor = theme.colorScheme.onPrimary; // putih di primer
    final tabBackground = theme.colorScheme.primary.withOpacity(0.12);

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: GNav(
            gap: 8,
            selectedIndex: _selectedIndex,
            onTabChange: (index) => setState(() => _selectedIndex = index),
            backgroundColor: backgroundColor,
            color: isDark ? Colors.white70 : Colors.grey[600],
            activeColor: activeIconColor,
            tabBackgroundColor: tabBackground,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            tabs: const [
              GButton(icon: Icons.home, text: 'Beranda'),
              GButton(icon: Icons.favorite, text: 'Favorit'),
              GButton(icon: Icons.shopping_cart, text: 'Keranjang'),
              GButton(icon: Icons.person, text: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
