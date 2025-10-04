import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  /// Getter untuk subtotal (total harga item ini: harga * kuantitas)
  double get subtotal => product.price * quantity;

  /// Getter untuk formatted total price (dengan pemisah ribuan)
  String get formattedTotalPrice {
    return 'Rp ${subtotal.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }

  /// Check if quantity can be incremented (based on product stock)
  bool canIncrement() {
    return quantity < product.stock;
  }

  /// Check if quantity can be decremented
  bool canDecrement() {
    return quantity > 1;
  }

  /// Increment quantity
  void increment() {
    if (canIncrement()) {
      quantity++;
    }
  }

  /// Decrement quantity
  void decrement() {
    if (canDecrement()) {
      quantity--;
    }
  }

  /// Copy with method untuk update product atau quantity
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
