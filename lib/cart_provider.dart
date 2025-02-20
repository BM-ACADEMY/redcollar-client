import 'package:flutter/material.dart';

class ProductProvider extends ChangeNotifier {
  // List of cart items
  List<Map<String, dynamic>> _cart = [];

  // Getter for cart items
  List<Map<String, dynamic>> get cart => _cart;

  // Check if a product is already in the cart
  bool isProductInCart(Map<String, dynamic> product) {
    return _cart.any((item) => item['id'] == product['id']);
  }

  // Add product to cart
  void addToCart(Map<String, dynamic> product) {
    if (isProductInCart(product)) {
      // If product is already in the cart, just update the quantity
      updateCartItem(product, product['quantity'] + 1);
    } else {
      _cart.add(
          {...product, 'quantity': 1}); // Add product to cart with quantity 1
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Remove product from cart
  void removeFromCart(Map<String, dynamic> product) {
    _cart.removeWhere((item) =>
        item['id'] == product['id']); // Remove product from cart by ID
    notifyListeners(); // Notify listeners about the change
  }

  // Update quantity of a product in the cart
  void updateCartItem(Map<String, dynamic> product, int newQuantity) {
    final index = _cart.indexWhere((item) => item['id'] == product['id']);
    if (index != -1 && newQuantity > 0) {
      _cart[index]['quantity'] = newQuantity; // Update quantity
      notifyListeners(); // Notify listeners about the change
    } else if (newQuantity <= 0) {
      // If quantity is less than or equal to 0, remove the item from the cart
      _cart.removeAt(index);
      notifyListeners(); // Notify listeners about the change
    }
  }

  // Calculate total price of the cart
  double get totalPrice {
    return _cart.fold(
        0.0, (sum, item) => sum + (item['price'] * item['quantity']));
  }
}
