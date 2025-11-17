import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/water_item.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  get orderProvider => null;

  void addItem(WaterItem waterItem) {
    final existingIndex = _items.indexWhere((item) => item.id == waterItem.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: waterItem.id,
        name: waterItem.name,
        price: waterItem.price,
        imageUrl: waterItem.imageUrl,
        category: waterItem.category,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // New methods

  void removeItemCompletely(WaterItem item) {
    _items.removeWhere((cartItem) => cartItem.id == item.id);
    notifyListeners();
  }

  void clearAllItems() {
    _items.clear();
    notifyListeners();
  }

  void increaseQuantity(WaterItem item) {
    final index = _items.indexWhere((cartItem) => cartItem.id == item.id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(WaterItem item) {
    final index = _items.indexWhere((cartItem) => cartItem.id == item.id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }
}
