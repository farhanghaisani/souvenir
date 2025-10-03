import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/order.dart';

class AdminService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();

      return response['is_admin'] == true;
    } catch (e) {
      return false;
    }
  }

  // === PRODUCT MANAGEMENT ===

  // Create new product
  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase
          .from('products')
          .insert({
            'name': name,
            'description': description,
            'price': price,
            'stock': stock,
            'image_url': imageUrl,
          })
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal membuat produk: $e');
    }
  }

  // Update product
  Future<Product> updateProduct(
    String productId, {
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (price != null) updates['price'] = price;
      if (stock != null) updates['stock'] = stock;
      if (imageUrl != null) updates['image_url'] = imageUrl;

      final response = await _supabase
          .from('products')
          .update(updates)
          .eq('id', productId)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Gagal update produk: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase.from('products').delete().eq('id', productId);
    } catch (e) {
      throw Exception('Gagal menghapus produk: $e');
    }
  }

  // === ORDER MANAGEMENT ===

  // Get all orders (admin view)
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*, product:products(*))')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil orders: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Gagal update status order: $e');
    }
  }

  // === STATISTICS ===

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Total products
      final productsResponse = await _supabase
          .from('products')
          .select('id');
      
      // Total orders
      final ordersResponse = await _supabase
          .from('orders')
          .select('id');

      // Total revenue
      final revenueResponse = await _supabase
          .from('orders')
          .select('total')
          .eq('status', 'delivered');

      double totalRevenue = 0;
      for (var order in revenueResponse) {
        totalRevenue += (order['total'] as num).toDouble();
      }

      // Pending orders
      final pendingResponse = await _supabase
          .from('orders')
          .select('id')
          .eq('status', 'pending');

      return {
        'total_products': (productsResponse as List).length,
        'total_orders': (ordersResponse as List).length,
        'total_revenue': totalRevenue,
        'pending_orders': (pendingResponse as List).length,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik: $e');
    }
  }
}