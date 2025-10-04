import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Order> createOrder({
    required List<CartItem> cartItems,
    required String recipientName,
    required String phone,
    required String address,
    required String city,
    String? notes,
    String? paymentMethod,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final total = cartItems.fold<double>(0, (sum, item) => sum + item.subtotal);

    final shippingAddress = '''
$recipientName
$phone
$address
$city
${notes != null && notes.isNotEmpty ? 'Catatan: $notes' : ''}
Metode Pembayaran: ${_getPaymentMethodLabel(paymentMethod ?? 'cod')}
''';

    try {
      // Insert order tanpa field 'quantity'
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': userId,
            'total': total,
            'status': 'pending',
            'shipping_address': shippingAddress,
            'payment_method': paymentMethod,
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // Insert order items dengan quantity masing-masing produk
      for (var item in cartItems) {
        await _supabase.from('order_items').insert({
          'order_id': orderId,
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        });

        // Kurangi stok produk
        final currentProduct = await _supabase
            .from('products')
            .select('stock')
            .eq('id', item.product.id)
            .single();

        final newStock = (currentProduct['stock'] as int) - item.quantity;
        
        await _supabase
            .from('products')
            .update({'stock': newStock})
            .eq('id', item.product.id);
      }

      return Order.fromJson(orderResponse);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cod':
        return 'Cash on Delivery';
      case 'transfer':
        return 'Transfer Bank';
      case 'online':
        return 'Pembayaran Online';
      default:
        return method;
    }
  }

  Future<List<Order>> getUserOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*, products(*))')
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': 'cancelled'})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Ambil detail pesanan dan item-itemnya untuk restore stok
      final orderResponse = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .eq('user_id', user.id)
          .single();

      // Restore stok untuk setiap item
      final orderItems = orderResponse['order_items'] as List<dynamic>;
      
      for (var item in orderItems) {
        final productId = item['product_id'];
        final quantity = item['quantity'] as int;

        // Ambil stok produk saat ini
        final productResponse = await _supabase
            .from('products')
            .select('stock')
            .eq('id', productId)
            .single();

        final currentStock = productResponse['stock'] as int;
        final newStock = currentStock + quantity;

        // Update stok produk
        await _supabase
            .from('products')
            .update({'stock': newStock})
            .eq('id', productId);
      }

      // Hapus order items terlebih dahulu
      await _supabase
          .from('order_items')
          .delete()
          .eq('order_id', orderId);

      // Kemudian hapus order
      await _supabase
          .from('orders')
          .delete()
          .eq('id', orderId)
          .eq('user_id', user.id);

    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}