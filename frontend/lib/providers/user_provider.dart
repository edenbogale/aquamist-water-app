// providers/user_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');

    if (userData != null) {
      final map = jsonDecode(userData);
      _user = User(
        name: map['name'],
        email: map['email'],
        phone: map['phone'],
        address: map['address'],
      );
      notifyListeners();
    }
  }

  void setUser(User newUser) {
    _user = newUser;
    notifyListeners();

    _saveUser(newUser);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'user',
        jsonEncode({
          'name': user.name,
          'email': user.email,
          'phone': user.phone,
          'address': user.address,
        }));
  }

  void clearUser() async {
    _user = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
}
