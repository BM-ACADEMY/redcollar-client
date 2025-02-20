import 'package:flutter/material.dart';
// Import your user model

class UserProvider with ChangeNotifier {
  // Define the properties in your UserProvider
  String _username = '';
  String _userId = '';
  String _email = '';

  String get username => _username;
  String get userId => _userId;
  String get email => _email;

  // Method to update the user data
  void login(String userId, String username, String email) {
    _userId = userId;
    _username = username;
    _email = email;
    notifyListeners(); // Notify listeners about the change
  }

  // Method to clear user data (e.g., logout)
  void logout() {
    _userId = '';
    _username = '';
    _email = '';
    notifyListeners();
  }
}
