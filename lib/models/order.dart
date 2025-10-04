class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final String? productName;
  final String? productImage;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.productName,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      productName: json['product_name'] as String?,
      productImage: json['product_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  double get subtotal => price * quantity;

  String get formattedPrice {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

class Order {
  final String id;
  final String userId;
  final double total;
  final String status;
  final String shippingAddress;
  final String? paymentMethod; // TAMBAHAN INI
  final DateTime createdAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.userId,
    required this.total,
    required this.status,
    required this.shippingAddress,
    this.paymentMethod, // TAMBAHAN INI
    required this.createdAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      shippingAddress: json['shipping_address'] as String,
      paymentMethod: json['payment_method'] as String?, // TAMBAHAN INI
      createdAt: DateTime.parse(json['created_at'] as String),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total': total,
      'status': status,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod, // TAMBAHAN INI
    };
  }

  String getStatusText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get formattedTotal {
    return 'Rp ${total.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final monthIndex = createdAt.month - 1;
    final monthName = (monthIndex >= 0 && monthIndex < 12) ? months[monthIndex] : '';

    return '${createdAt.day} $monthName ${createdAt.year}';
  }

  Order copyWith({
    String? status,
    String? paymentMethod, // TAMBAHAN INI
  }) {
    return Order(
      id: id,
      userId: userId,
      total: total,
      status: status ?? this.status,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod, // TAMBAHAN INI
      createdAt: createdAt,
      items: items,
    );
  }
}