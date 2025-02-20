import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];
  final List<Map<String, dynamic>> _cart = [];

  // Getters
  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);
  List<Map<String, dynamic>> get cart => List.unmodifiable(_cart);

  // Check if a product is a favorite
  bool isFavorite(Map<String, dynamic> product) {
    return _favorites.any((item) => item['name'] == product['name']);
  }

  // Toggle favorite status for a product
  void toggleFavorite(Map<String, dynamic> product) {
    final index =
        _favorites.indexWhere((item) => item['name'] == product['name']);
    if (index >= 0) {
      _favorites.removeAt(index); // Remove from favorites
    } else {
      _favorites.add(product); // Add to favorites
    }
    notifyListeners();
  }

  // Add a product to the cart
  void addToCart(Map<String, dynamic> product) {
    final index = _cart.indexWhere((item) => item['name'] == product['name']);
    if (index >= 0) {
      _cart[index]['quantity'] +=
          1; // Increment quantity if product already exists
    } else {
      _cart.add({
        ...product,
        'quantity': 1
      }); // Add as new product with initial quantity
    }
    notifyListeners();
  }

  // Remove a product from the cart
  void removeFromCart(Map<String, dynamic> product) {
    _cart.removeWhere((item) => item['name'] == product['name']);
    notifyListeners();
  }

  // Update the quantity of a cart item
  void updateCartQuantity(Map<String, dynamic> product, int quantity) {
    final index = _cart.indexWhere((item) => item['name'] == product['name']);
    if (index >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(index); // Remove the item if quantity is zero or less
      } else {
        _cart[index]['quantity'] = quantity; // Update the item's quantity
      }
      notifyListeners();
    }
  }

  // Update specific cart item attributes (color or size)
  void updateCartItemAttribute(
      Map<String, dynamic> product, String attribute, dynamic newValue) {
    final index = _cart.indexWhere((item) => item['name'] == product['name']);
    if (index >= 0) {
      _cart[index][attribute] = newValue; // Update the specific attribute
      notifyListeners();
    }
  }

  // Shortcut methods for updating color and size
  void updateCartItemColor(Map<String, dynamic> product, String newColor) {
    updateCartItemAttribute(product, 'color', newColor);
  }

  void updateCartItemSize(Map<String, dynamic> product, String newSize) {
    updateCartItemAttribute(product, 'size', newSize);
  }
}
