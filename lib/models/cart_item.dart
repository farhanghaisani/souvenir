import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  // Getter untuk subtotal
  double get subtotal => product.price * quantity;

  // Getter untuk formatted total price
  String get formattedTotalPrice {
    return 'Rp ${subtotal.toStringAsFixed(0)}';
  }

  // Check if can increment quantity
  bool canIncrement() {
    return quantity < product.stock;
  }

  // Check if can decrement quantity
  bool canDecrement() {
    return quantity > 1;
  }

  // Increment quantity
  void increment() {
    if (canIncrement()) {
      quantity++;
    }
  }

  // Decrement quantity
  void decrement() {
    if (canDecrement()) {
      quantity--;
    }
  }

  // Copy with method untuk update quantity
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