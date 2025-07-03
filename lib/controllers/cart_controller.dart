import 'package:get/get.dart';
import 'package:wolvystore/models/cartitem_model.dart';
import 'package:wolvystore/models/product_model.dart';

class CartController extends GetxController {
  var items = <CartItem>[].obs;
  var selectedItemIds = <String>[].obs;

  /// Tambahkan produk ke keranjang
  void addToCart(Product product, int quantity) {
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      items[index].quantity += quantity;
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    // Otomatis pilih item yang ditambahkan
    selectedItemIds.addIf(
      !selectedItemIds.contains(product.id.toString()),
      product.id.toString(),
    );
  }

  /// Hapus produk dari keranjang
  void removeFromCart(String productId) {
    items.removeWhere((item) => item.product.id == productId);
    selectedItemIds.remove(productId);
  }

  /// Update jumlah produk secara manual
  void updateQuantity(String productId, int newQty) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      items[index].quantity = newQty;
      items.refresh();
    }
  }

  /// Tambah kuantitas
  void increaseQuantity(String productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      items[index].quantity++;
      items.refresh();
    }
  }

  /// Kurangi kuantitas
  void decreaseQuantity(String productId) {
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index != -1 && items[index].quantity > 1) {
      items[index].quantity--;
      items.refresh();
    }
  }

  /// Toggle centang (pilih/lepaskan) produk untuk checkout
  void toggleSelection(String productId) {
    if (selectedItemIds.contains(productId)) {
      selectedItemIds.remove(productId);
    } else {
      selectedItemIds.add(productId);
    }
  }

  /// Toggle semua centang (Pilih Semua / Hilangkan Semua)
  void toggleSelectAll(
    List<String> allProductIds,
    bool isCurrentlyAllSelected,
  ) {
    if (isCurrentlyAllSelected) {
      selectedItemIds.clear();
    } else {
      selectedItemIds.assignAll(allProductIds);
    }
  }

  /// Total harga hanya dari item yang dipilih
  int get totalSelectedPrice {
    return items
        .where((item) => selectedItemIds.contains(item.product.id.toString()))
        .fold(0, (sum, item) => sum + (item.product.harga * item.quantity));
  }

  /// Kosongkan keranjang
  void clearCart() {
    items.clear();
    selectedItemIds.clear();
  }
}
