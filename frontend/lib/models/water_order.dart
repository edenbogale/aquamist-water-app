// lib/models/water_order.dart
class WaterOrder {
  final String id;
  final String status; // e.g., 'confirmed', 'delivering', 'delivered'
  final String items;
  final String orderDate;
  final String estimatedDelivery;
  final double? latitude;
  final double? longitude;

  WaterOrder({
    required this.id,
    required this.status,
    required this.items,
    required this.orderDate,
    required this.estimatedDelivery,
    this.latitude,
    this.longitude,
  });

  /// Robust parsing helper for either string or numeric values
  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) {
      final parsed = double.tryParse(v);
      return parsed;
    }
    return null;
  }

  /// Create WaterOrder from backend JSON (handles several common shapes)
  factory WaterOrder.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['order_id'] ?? '').toString();
    final status = (json['status'] ?? 'confirmed').toString();

    // items may be a string or a list
    String items;
    if (json['items'] is String) {
      items = json['items'];
    } else if (json['items'] is List) {
      items = (json['items'] as List).join(', ');
    } else if (json['items'] is Map) {
      items = json['items'].toString();
    } else {
      items = (json['items'] ?? '').toString();
    }

    final orderDate = (json['orderDate'] ??
            json['order_date'] ??
            json['created_at'] ??
            json['ordered_at'] ??
            '')
        .toString();

    final estimatedDelivery = (json['estimatedDelivery'] ??
            json['estimated_delivery'] ??
            json['eta'] ??
            '')
        .toString();

    final latitude = _toDouble(json['latitude'] ?? json['lat']);
    final longitude =
        _toDouble(json['longitude'] ?? json['lng'] ?? json['long']);

    return WaterOrder(
      id: id,
      status: status,
      items: items,
      orderDate: orderDate,
      estimatedDelivery: estimatedDelivery,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Convert model to JSON (useful for sending updates to backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'items': items,
      'orderDate': orderDate,
      'estimatedDelivery': estimatedDelivery,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create a copy with changes (used when updating local state)
  WaterOrder copyWith({
    String? id,
    String? status,
    String? items,
    String? orderDate,
    String? estimatedDelivery,
    double? latitude,
    double? longitude,
  }) {
    return WaterOrder(
      id: id ?? this.id,
      status: status ?? this.status,
      items: items ?? this.items,
      orderDate: orderDate ?? this.orderDate,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'WaterOrder(id: $id, status: $status, items: $items, orderDate: $orderDate, estimatedDelivery: $estimatedDelivery, lat: $latitude, lng: $longitude)';
  }
}
