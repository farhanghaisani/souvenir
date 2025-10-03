import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import 'dart:typed_data';

class AdminProductService {
  final supabase = Supabase.instance.client;

  // CREATE - Tambah produk baru
  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    try {
      String? imageUrl;

      // Upload gambar jika ada
      if (imageBytes != null) {
        imageUrl = await _uploadProductImage(imageBytes, imageExtension ?? 'jpg');
      }

      // Insert ke database
      final response = await supabase.from('products').insert({
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category': category,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambah produk: $e');
    }
  }

  // READ - Ambil semua produk
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil produk: $e');
    }
  }

  // READ - Ambil produk berdasarkan ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('id', id)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil produk: $e');
    }
  }

  // UPDATE - Update produk
  Future<Product> updateProduct({
    required String id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    Uint8List? imageBytes,
    String? imageExtension,
    bool removeImage = false,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (stock != null) updates['stock'] = stock;
      if (category != null) updates['category'] = category;

      // Hapus gambar lama jika ada
      if (removeImage || imageBytes != null) {
        final product = await getProductById(id);
        if (product.imageUrl != null) {
          await _deleteProductImage(product.imageUrl!);
        }
        updates['image_url'] = null;
      }

      // Upload gambar baru jika ada
      if (imageBytes != null) {
        final imageUrl = await _uploadProductImage(imageBytes, imageExtension ?? 'jpg');
        updates['image_url'] = imageUrl;
      }

      final response = await supabase
          .from('products')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update produk: $e');
    }
  }

  // DELETE - Hapus produk
  Future<void> deleteProduct(String id) async {
    try {
      // Hapus gambar jika ada
      final product = await getProductById(id);
      if (product.imageUrl != null) {
        await _deleteProductImage(product.imageUrl!);
      }

      // Hapus dari database
      await supabase.from('products').delete().eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  // SEARCH - Cari produk
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mencari produk: $e');
    }
  }

  // Filter by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await supabase
          .from('products')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil produk: $e');
    }
  }

  // Helper: Upload gambar produk
  Future<String> _uploadProductImage(Uint8List bytes, String fileExt) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'products/$fileName';

      await supabase.storage
          .from('products')
          .uploadBinary(filePath, bytes);

      return supabase.storage.from('products').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Gagal upload gambar: $e');
    }
  }

  // Helper: Hapus gambar produk
  Future<void> _deleteProductImage(String imageUrl) async {
    try {
      final fileName = imageUrl.split('/').last;
      await supabase.storage
          .from('products')
          .remove(['products/$fileName']);
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}