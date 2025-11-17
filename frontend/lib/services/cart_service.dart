import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/water_item.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _cartItems = [];
  double _deliveryFee = 5.99;
  double _taxRate = 0.08; // 8% tax

  // Getters
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => _cartItems.length;
  double get deliveryFee => _deliveryFee;
  double get taxRate => _taxRate;

  // Calculate subtotal (before tax and delivery)
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Calculate tax amount
  double get taxAmount {
    return subtotal * _taxRate;
  }

  // Calculate total amount (including tax and delivery)
  double get totalAmount {
    return subtotal + taxAmount + _deliveryFee;
  }

  // Add item to cart
  void addItem(WaterItem waterItem, {int quantity = 1}) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.id == waterItem.id);

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(
        id: waterItem.id,
        name: waterItem.name,
        price: waterItem.price,
        imageUrl: waterItem.imageUrl,
        category: waterItem.category,
        quantity: quantity,
      ));
    }

    notifyListeners();
    _saveCartToStorage();
  }

  // Remove item completely from cart
  void removeItem(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
    _saveCartToStorage();
  }

  // Update item quantity
  void updateQuantity(String itemId, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);

    if (index >= 0) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
      _saveCartToStorage();
    }
  }

  // Increment item quantity
  void incrementQuantity(String itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _cartItems[index].quantity++;
      notifyListeners();
      _saveCartToStorage();
    }
  }

  // Decrement item quantity
  void decrementQuantity(String itemId) {
    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
      _saveCartToStorage();
    }
  }

  // Get quantity of specific item
  int getItemQuantity(String itemId) {
    final item = _cartItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        imageUrl: '',
        category: '',
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Check if item exists in cart
  bool isItemInCart(String itemId) {
    return _cartItems.any((item) => item.id == itemId);
  }

  // Clear entire cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _saveCartToStorage();
  }

  // Apply discount
  double applyDiscount(double discountPercentage) {
    double discountAmount = subtotal * (discountPercentage / 100);
    return discountAmount;
  }

  // Calculate total with discount
  double getTotalWithDiscount(double discountPercentage) {
    double discountAmount = applyDiscount(discountPercentage);
    return totalAmount - discountAmount;
  }

  // Set delivery fee
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  // Get cart summary
  Map<String, dynamic> getCartSummary() {
    return {
      'items': _cartItems
          .map((item) => {
                'id': item.id,
                'name': item.name,
                'price': item.price,
                'quantity': item.quantity,
                'totalPrice': item.totalPrice,
              })
          .toList(),
      'itemCount': itemCount,
      'uniqueItemCount': uniqueItemCount,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'deliveryFee': _deliveryFee,
      'totalAmount': totalAmount,
    };
  }

  // Validate cart before checkout
  bool validateCart() {
    return _cartItems.isNotEmpty &&
        _cartItems.every((item) => item.quantity > 0);
  }

  // Process checkout
  Future<bool> processCheckout() async {
    if (!validateCart()) {
      return false;
    }

    try {
      // Simulate API call for order processing
      await Future.delayed(Duration(seconds: 2));

      // Clear cart after successful checkout
      clearCart();

      return true;
    } catch (e) {
      print('Checkout failed: $e');
      return false;
    }
  }

  // Save cart to local storage (simulated)
  void _saveCartToStorage() {
    // In a real app, you would save to SharedPreferences or local database
    final cartData = jsonEncode(_cartItems
        .map((item) => {
              'id': item.id,
              'name': item.name,
              'price': item.price,
              'imageUrl': item.imageUrl,
              'category': item.category,
              'quantity': item.quantity,
            })
        .toList());

    // Save to storage
    print('Cart saved to storage: $cartData');
  }

  // Load cart from local storage (simulated)
  void loadCartFromStorage() {
    // In a real app, you would load from SharedPreferences or local database
    // This is just a placeholder for the functionality
    print('Cart loaded from storage');
  }

  // Get items by category
  List<CartItem> getItemsByCategory(String category) {
    return _cartItems.where((item) => item.category == category).toList();
  }

  // Get most expensive item
  CartItem? getMostExpensiveItem() {
    if (_cartItems.isEmpty) return null;
    return _cartItems.reduce((a, b) => a.price > b.price ? a : b);
  }

  // Get least expensive item
  CartItem? getLeastExpensiveItem() {
    if (_cartItems.isEmpty) return null;
    return _cartItems.reduce((a, b) => a.price < b.price ? a : b);
  }

  // Calculate average item price
  double getAverageItemPrice() {
    if (_cartItems.isEmpty) return 0.0;
    return subtotal / itemCount;
  }

  // Get cart statistics
  Map<String, dynamic> getCartStatistics() {
    return {
      'totalItems': itemCount,
      'uniqueItems': uniqueItemCount,
      'averagePrice': getAverageItemPrice(),
      'mostExpensiveItem': getMostExpensiveItem()?.name ?? 'None',
      'leastExpensiveItem': getLeastExpensiveItem()?.name ?? 'None',
      'categories': _cartItems.map((item) => item.category).toSet().toList(),
    };
  }
}
