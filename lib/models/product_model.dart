class Product {
  final String id;
  final String namaProduk;
  final int harga;
  final String? fotoProduk;
  final String kategori;
  final String? deskripsi;
  final int stok;

  Product({
    required this.id,
    required this.namaProduk,
    required this.harga,
    this.fotoProduk,
    required this.kategori,
    this.deskripsi,
    required this.stok,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      namaProduk: json['nama_produk'] ?? '',
      harga:
          json['harga'] is int
              ? json['harga']
              : int.tryParse(json['harga'].toString()) ?? 0,
      fotoProduk: json['foto_produk'],
      kategori: json['kategori_id'] ?? '',
      deskripsi: json['deskripsi'],
      stok:
          json['stok'] is int
              ? json['stok']
              : int.tryParse(json['stok'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_produk': namaProduk,
      'harga': harga,
      'foto_produk': fotoProduk,
      'kategori_id': kategori,
      'deskripsi': deskripsi,
      'stok': stok,
    };
  }
}
