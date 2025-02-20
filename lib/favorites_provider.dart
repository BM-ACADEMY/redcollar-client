import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  void addFavorite(Map<String, dynamic> product) {
    if (!_favorites.any((item) => item['docId'] == product['docId'])) {
      _favorites.add(product);
      notifyListeners();
    }
  }

  void removeFavorite(String docId) {
    _favorites.removeWhere((item) => item['docId'] == docId);
    notifyListeners();
  }

  bool isFavorite(String docId) {
    return _favorites.any((item) => item['docId'] == docId);
  }
}
