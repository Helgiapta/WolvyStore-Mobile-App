import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wolvystore/models/product_model.dart';
import 'package:wolvystore/models/cartitem_model.dart';

class ProductController extends GetxController {
  final supabase = Supabase.instance.client;

  final List<Map<String, dynamic>> categories = [
    {'id': '', 'icon': Icons.all_inclusive, 'label': 'Semua Produk'},
    {'id': 'kat-001', 'icon': Icons.electrical_services, 'label': 'Elektronik'},
    {'id': 'kat-002', 'icon': Icons.checkroom, 'label': 'Fashion'},
    {'id': 'kat-003', 'icon': Icons.face, 'label': 'Kecantikan'},
    {'id': 'kat-004', 'icon': Icons.healing, 'label': 'Kesehatan'},
    {'id': 'kat-005', 'icon': Icons.child_friendly, 'label': 'Ibu & Bayi'},
    {'id': 'kat-006', 'icon': Icons.home, 'label': 'Rumah Tangga'},
    {'id': 'kat-007', 'icon': Icons.restaurant, 'label': 'Makanan & Minuman'},
    {'id': 'kat-008', 'icon': Icons.extension, 'label': 'Hobi & Koleksi'},
    {
      'id': 'kat-009',
      'icon': Icons.sports_soccer,
      'label': 'Olahraga & Outdoor',
    },
    {'id': 'kat-010', 'icon': Icons.car_repair, 'label': 'Otomotif'},
    {'id': 'kat-011', 'icon': Icons.computer, 'label': 'Komputer & Aksesoris'},
    {'id': 'kat-012', 'icon': Icons.videogame_asset, 'label': 'Gaming'},
  ];

  var allProducts = <Product>[].obs;
  var displayedProducts = <Product>[].obs;
  var randomTopProducts = <Product>[].obs;

  final favoriteIds = <String>{}.obs;
  var cartItems = <CartItem>[].obs;

  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var isLoading = false.obs;

  RxString userName = ''.obs;
  RxString userPhoto = ''.obs;

  @override
  void onInit() {
    fetchUserProfile();
    fetchAllProducts();
    super.onInit();
  }

  Future<void> fetchUserProfile() async {
    try {
      final uid = supabase.auth.currentUser?.id;
      if (uid == null) return;

      final response =
          await supabase
              .from('user_acc')
              .select('nama, foto_profil')
              .eq('uid', uid)
              .single();

      userName.value = response['nama'] ?? 'Pengguna';
      userPhoto.value = response['foto_profil'] ?? '';
    } catch (e) {
      print('Error fetch profile: $e');
    }
  }

  Future<void> fetchAllProducts() async {
    isLoading.value = true;

    try {
      final response = await supabase.from('produk').select();
      final data = response as List;
      final products = data.map((e) => Product.fromJson(e)).toList();

      allProducts.assignAll(products);

      if (products.length >= 4) {
        final random = Random();
        final shuffled = [...products]..shuffle(random);
        randomTopProducts.value = shuffled.take(4).toList();
      } else {
        randomTopProducts.value = [...products];
      }

      applyFilter();
    } catch (e) {
      print('Fetch products error: $e');
    }

    isLoading.value = false;
  }

  void applyFilter() {
    List<Product> filtered = List.from(allProducts);

    if (searchQuery.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (product) => product.namaProduk.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                ),
              )
              .toList();
    }

    if (selectedCategory.value.isNotEmpty) {
      filtered =
          filtered
              .where(
                (product) =>
                    product.kategori.toLowerCase() ==
                    selectedCategory.value.toLowerCase(),
              )
              .toList();
    }

    displayedProducts.value = filtered;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void setCategory(String kategoriId) {
    selectedCategory.value =
        selectedCategory.value == kategoriId ? '' : kategoriId;
    applyFilter();
  }

  void toggleFavorite(String productId) {
    if (favoriteIds.contains(productId)) {
      favoriteIds.remove(productId);
    } else {
      favoriteIds.add(productId);
    }
  }

  List<Product> get favoriteProducts =>
      allProducts.where((p) => favoriteIds.contains(p.id.toString())).toList();

  void removeFromCart(Product product) {
    cartItems.removeWhere((item) => item.product.id == product.id);
  }

  void clearCart() {
    cartItems.clear();
  }
}
