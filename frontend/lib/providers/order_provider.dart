// lib/providers/order_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/water_order.dart';

class OrderProvider with ChangeNotifier {
  final String baseUrl;

  OrderProvider({this.baseUrl = 'http://localhost:8080/water_api'});

  final List<WaterOrder> _orders = [];
  List<WaterOrder> get orders => List.unmodifiable(_orders);

  /// Add a new order locally (used by CartScreen after successful createOrder.php)
  /// If the order already exists (same id) it replaces it; otherwise it inserts at the front.
  void addOrder(WaterOrder order) {
    final idx = _orders.indexWhere((o) => o.id == order.id);
    if (idx >= 0) {
      _orders[idx] = order;
    } else {
      _orders.insert(0, order);
    }
    notifyListeners();
  }

  /// Replace all local orders (useful if you want to completely refresh from server)
  void setOrders(List<WaterOrder> orders) {
    _orders
      ..clear()
      ..addAll(orders);
    notifyListeners();
  }

  /// Remove order locally
  void removeOrder(String orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  /// Fetch orders from backend. The backend may return:
  ///  - a top-level list: [ {...}, {...} ]
  ///  - or { "orders": [ ... ] } or { "data": [ ... ] }
  Future<void> fetchOrders({String? userId}) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/get_orders.php${userId != null ? '?user_id=$userId' : ''}');
      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('Failed to fetch orders: ${res.statusCode}');
      }

      final decoded = jsonDecode(res.body);

      List<dynamic> list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['orders'] is List)
          list = decoded['orders'];
        else if (decoded['data'] is List)
          list = decoded['data'];
        else {
          // try to find the first list in the map
          final found =
              decoded.values.firstWhere((v) => v is List, orElse: () => []);
          list = (found is List) ? found : [];
        }
      } else {
        list = [];
      }

      final parsed = list
          .map((e) => e is Map<String, dynamic>
              ? WaterOrder.fromJson(e)
              : WaterOrder.fromJson({'id': e.toString()}))
          .toList();

      setOrders(parsed);
    } catch (e) {
      if (kDebugMode) print('fetchOrders error: $e');
      rethrow;
    }
  }

  /// Mark an order as delivered locally and try to update backend via update_status.php
  /// Keeps optimistic update behaviour (updates UI first).
  Future<void> markAsDelivered(String orderId) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;

    final old = _orders[idx];
    final updated =
        old.copyWith(status: 'delivered', estimatedDelivery: 'Delivered');
    _orders[idx] = updated;
    notifyListeners();

    // send update to backend
    try {
      final uri = Uri.parse('$baseUrl/update_status.php');
      final body = jsonEncode({'order_id': orderId, 'status': 'delivered'});
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (res.statusCode != 200) {
        if (kDebugMode)
          print('Server failed to update order: ${res.statusCode} ${res.body}');
        // optional: revert local change or handle retry logic
      }
    } catch (e) {
      if (kDebugMode) print('markAsDelivered error: $e');
    }
  }

  /// Optional helper: returns running (not delivered) orders
  List<WaterOrder> getRunningOrders() {
    return _orders.where((o) => o.status.toLowerCase() != 'delivered').toList();
  }

  /// Optional helper: returns delivered orders
  List<WaterOrder> getHistoryOrders() {
    return _orders.where((o) => o.status.toLowerCase() == 'delivered').toList();
  }

  /// Load orders from a raw JSON string (useful for cached responses)
  void loadFromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    List<dynamic> list = [];
    if (decoded is List)
      list = decoded;
    else if (decoded is Map && decoded['orders'] is List)
      list = decoded['orders'];
    final parsed = list
        .map((e) => WaterOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    setOrders(parsed);
  }
}
