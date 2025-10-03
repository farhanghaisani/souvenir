import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final _supabase = Supabase.instance.client;

  // Create new order
  Future<Order> createOrder({
    required List<CartItem> cartItems,
    required String shippingAddress,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Calculate total
      final total = cartItems.fold<double>(
        0,
        (sum, item) => sum + item.subtotal,
      );

      // Create order
      final orderData = {
        'user_id': userId,
        'total': total,
        'status': 'pending',
        'shipping_address': shippingAddress,
      };

      final orderResponse =
          await _supabase.from('orders').insert(orderData).select().single();

      final orderId = orderResponse['id'];

      // Create order items
      final orderItems = cartItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      await _supabase.from('order_items').insert(orderItems);

      // Update product stock
      for (var item in cartItems) {
        await _supabase
            .from('products')
            .update({'stock': item.product.stock - item.quantity}).eq(
                'id', item.product.id);
      }

      return Order.fromJson(orderResponse);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get user orders
  Future<List<Order>> getUserOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _supabase
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Get order detail with items
  Future<Order> getOrderDetail(String orderId) async {
    try {
      // Get order
      final orderResponse =
          await _supabase.from('orders').select('*').eq('id', orderId).single();

      // Get order items with product details
      final itemsResponse = await _supabase.from('order_items').select('''
            *,
            products (
              name,
              image_url
            )
          ''').eq('order_id', orderId);

      // Map items with product details
      final items = (itemsResponse as List).map((json) {
        return OrderItem.fromJson({
          ...json,
          'product_name': json['products']['name'],
          'product_image': json['products']['image_url'],
        });
      }).toList();

      return Order.fromJson({
        ...orderResponse,
        'items': items.map((item) => item.toJson()).toList(),
      });
    } catch (e) {
      throw Exception('Failed to fetch order detail: $e');
    }
  }

  // Cancel order (update status jadi cancelled)
  Future<void> cancelOrder(String orderId) async {
    try {
      // Get order items to restore stock
      final items = await _supabase
          .from('order_items')
          .select('product_id, quantity')
          .eq('order_id', orderId);

      // Restore stock
      for (var item in items) {
        final product = await _supabase
            .from('products')
            .select('stock')
            .eq('id', item['product_id'])
            .single();

        await _supabase
            .from('products')
            .update({'stock': product['stock'] + item['quantity']}).eq(
                'id', item['product_id']);
      }

      // Update order status
      await _supabase
          .from('orders')
          .update({'status': 'cancelled'}).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // Delete order permanently (hapus dari database)
  Future<void> deleteOrder(String orderId) async {
    try {
      // 1. Get order items
      final items = await _supabase
          .from('order_items')
          .select('product_id, quantity')
          .eq('order_id', orderId);

      // 2. Restore stock
      for (var item in items) {
        final product = await _supabase
            .from('products')
            .select('stock')
            .eq('id', item['product_id'])
            .single();

        await _supabase
            .from('products')
            .update({'stock': product['stock'] + item['quantity']}).eq(
                'id', item['product_id']);
      }

      // 3. Delete order items
      await _supabase.from('order_items').delete().eq('order_id', orderId);

      // 4. Delete order (pakai 'id' bukan 'order_id')
      final result = await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId) // ✅ Ganti ke 'id'
          .select();

      if (result.isEmpty) {
        throw Exception('Gagal menghapus pesanan');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
