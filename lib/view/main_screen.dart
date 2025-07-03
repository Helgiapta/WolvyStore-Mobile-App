import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolvystore/controllers/product_controller.dart';
import 'package:wolvystore/controllers/theme_controller.dart';
import 'package:wolvystore/utils/session_manager.dart';
import 'package:wolvystore/view/widgets/product_grid.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  final productController = Get.find<ProductController>();
  final ScrollController _scrollController = ScrollController();
  bool _hideHeader = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    productController.fetchAllProducts();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      if (offset > 50 && !_hideHeader) {
        setState(() => _hideHeader = true);
      } else if (offset <= 50 && _hideHeader) {
        setState(() => _hideHeader = false);
      }
    });
  }

  Future<void> fetchUserProfile() async {
    final uid = await SessionManager.getUID();
    if (uid == null) return;

    final data =
        await productController.supabase
            .from('user_acc')
            .select('nama, foto_profil')
            .eq('uid', uid)
            .maybeSingle();

    if (data != null) {
      productController.userName.value = data['nama'] ?? 'Pengguna';
      productController.userPhoto.value = data['foto_profil'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF222831) : const Color(0xFFE3FDFD);
    final cardColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFCBF1F5);
    final inputColor =
        isDark ? const Color(0xFF393E46) : const Color(0xFFA6E3E9);
    final accentColor =
        isDark ? const Color(0xFF948979) : const Color(0xFF71C9CE);
    final textColor = isDark ? Colors.white : Colors.black;

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // Perkiraan tinggi header: padding atas (20) + tinggi row profil (~36) + padding (16) + tinggi TextField (~48) + padding bawah (44) + statusBarHeight
    // Sekitar 20 + 36 + 16 + 48 + 44 = 164. Kita gunakan 170 untuk aman.
    const double headerHeight = 170; // Tinggi tetap untuk header
    const double categoryHeight = 70; // Tinggi tetap untuk kategori

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Obx(() {
        final selectedCategory = productController.selectedCategory.value;
        final searchQuery = productController.searchQuery.value;
        final randomProducts =
            (selectedCategory.isEmpty && searchQuery.isEmpty)
                ? productController.randomTopProducts
                : [];
        final displayedProducts = productController.displayedProducts;

        return Stack(
          children: [
            // Konten produk yang dapat discroll
            Positioned.fill(
              top:
                  headerHeight +
                  categoryHeight +
                  statusBarHeight +
                  16, // Total tinggi fixed header + kategori + sedikit padding
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (randomProducts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Rekomendasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: randomProducts.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                          itemBuilder:
                              (_, index) =>
                                  ProductGrid(data: randomProducts[index]),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Produk Lainnya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemBuilder:
                            (_, index) =>
                                ProductGrid(data: displayedProducts[index]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Header yang fixed di bagian atas
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  ClipPath(
                    clipper: BottomCurveClipper(),
                    child: Container(
                      color: accentColor,
                      padding: EdgeInsets.fromLTRB(
                        20,
                        20 + statusBarHeight,
                        20,
                        44,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final nama = productController.userName.value;
                            final foto = productController.userPhoto.value;
                            final greeting = greetingMessage();

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundImage:
                                          (foto.isNotEmpty)
                                              ? NetworkImage(foto)
                                              : null,
                                      backgroundColor: Colors.grey[400],
                                      child:
                                          (foto.isEmpty)
                                              ? const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Halo, $nama',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        Text(
                                          greeting,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(color: textColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        color: textColor,
                                      ),
                                      onPressed:
                                          () => themeController.toggleTheme(),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                      ),
                                      onPressed: () async {
                                        await SessionManager.clearSession();
                                        Get.offAllNamed('/login');
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: productController.setSearchQuery,
                            decoration: InputDecoration(
                              hintText: 'Cari produk...'.tr,
                              prefixIcon: Icon(
                                Icons.search,
                                color: textColor.withOpacity(0.7),
                              ),
                              filled: true,
                              fillColor: inputColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              hintStyle: TextStyle(
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            style: TextStyle(color: textColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Kategori yang fixed tepat di bawah header
                  Container(
                    color: backgroundColor, // Latar belakang kategori
                    height: categoryHeight,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children:
                          productController.categories.map((cat) {
                            final id = cat['id'];
                            final isSelected =
                                productController.selectedCategory.value == id;

                            return GestureDetector(
                              onTap: () {
                                productController.setCategory(
                                  isSelected ? '' : id,
                                );
                                _animationController.forward(from: 0);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected ? accentColor : cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ScaleTransition(
                                      scale: Tween(
                                        begin: 1.0,
                                        end: 1.2,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: _animationController,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                      child: Icon(
                                        cat['icon'],
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : textColor.withOpacity(0.7),
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        cat['label'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 60,
      size.width,
      size.height - 50,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
