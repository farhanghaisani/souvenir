import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};
  
  // Jumlah item unik dalam keranjang
  int get itemCount => _items.length;
  
  // Total kuantitas semua produk
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  // Total harga semua produk
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  // Formatted total amount
  String get formattedTotalAmount => 'Rp ${totalAmount.toStringAsFixed(0)}';

  // Tambah produk ke keranjang
  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // Cek apakah masih bisa menambah quantity
      final currentItem = _items[product.id]!;
      final newQuantity = currentItem.quantity + quantity;
      
      if (newQuantity <= product.stock) {
        _items[product.id] = currentItem.copyWith(quantity: newQuantity);
      } else {
        // Jika melebihi stok, set ke maksimal stok
        _items[product.id] = currentItem.copyWith(quantity: product.stock);
      }
    } else {
      // Tambah produk baru ke keranjang
      final validQuantity = quantity > product.stock ? product.stock : quantity;
      _items[product.id] = CartItem(
        product: product,
        quantity: validQuantity,
      );
    }
    notifyListeners();
  }

  // Hapus item dari keranjang
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Update quantity item
  void updateQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        _items.remove(productId);
      } else {
        final cartItem = _items[productId]!;
        // Pastikan tidak melebihi stok
        final validQuantity = quantity > cartItem.product.stock 
            ? cartItem.product.stock 
            : quantity;
        _items[productId] = cartItem.copyWith(quantity: validQuantity);
      }
      notifyListeners();
    }
  }

  // Increment quantity
  void incrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      final cartItem = _items[productId]!;
      if (cartItem.canIncrement()) {
        cartItem.increment();
        notifyListeners();
      }
    }
  }

  // Decrement quantity
  void decrementQuantity(String productId) {
    if (_items.containsKey(productId)) {
      final cartItem = _items[productId]!;
      if (cartItem.canDecrement()) {
        cartItem.decrement();
        notifyListeners();
      } else {
        // Jika quantity = 1, hapus item
        removeItem(productId);
      }
    }
  }

  // Cek apakah produk ada di keranjang
  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  // Get quantity produk di keranjang
  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  // Clear semua item
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Get list of cart items
  List<CartItem> get cartItems => _items.values.toList();

  void clearCart() {}
}