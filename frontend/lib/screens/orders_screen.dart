// screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../models/water_order.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import 'map_screen.dart';

// 💧 Define water blue
const Color kWaterBlue = Color(0xFF2196F3);

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderProvider>(context).orders;

    final runningOrders =
        orders.where((o) => o.status.toLowerCase() != 'delivered').toList();
    final historyOrders =
        orders.where((o) => o.status.toLowerCase() == 'delivered').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: kWaterBlue, //
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false),
          ),
          title: const Text(
            'Water Orders',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Running'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OrderList(
                orders: runningOrders, emptyMessage: 'No running orders.'),
            OrderList(
                orders: historyOrders, emptyMessage: 'No order history yet.'),
          ],
        ),
      ),
    );
  }
}

class OrderList extends StatelessWidget {
  final List<WaterOrder> orders;
  final String emptyMessage;

  const OrderList({Key? key, required this.orders, required this.emptyMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
          child: Text(emptyMessage,
              style: const TextStyle(fontSize: 18, color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => OrderCard(order: orders[index]),
    );
  }
}

class OrderCard extends StatelessWidget {
  final WaterOrder order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.orange;
      case 'preparing':
        return Colors.amber;
      case 'delivering':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'preparing':
        return Icons.inventory;
      case 'delivering':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      default:
        return Icons.info_outline;
    }
  }

  /// Accepts addresses saved as "lat, long" (e.g. " -1.28333, 36.81667 ").
  LatLng? _latLngFromAddress(String? address) {
    if (address == null) return null;
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;

    // If address already looks like "lat, long", parse it
    if (trimmed.contains(',')) {
      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        final a = parts[0].trim();
        final b = parts[1].trim();
        final lat = double.tryParse(a);
        final lng = double.tryParse(b);
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
    }

    // Could add extra parsing here (e.g., "lat: ..., lng: ..." or other formats)
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_getStatusIcon(order.status),
              color: _getStatusColor(order.status), size: 30),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order ID: ${order.id}',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text(order.items,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('Ordered on: ${order.orderDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              if (order.estimatedDelivery.toLowerCase() != 'delivered') ...[
                const SizedBox(height: 4),
              ],
            ]),
          ),
        ]),
        if (order.status.toLowerCase() != 'delivered') ...[
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              onPressed: () {
                // 1) Get user and their saved address
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No user found. Please sign in.')));
                  return;
                }

                final savedAddress =
                    user.address; // uses your existing User model field
                final customerLatLng = _latLngFromAddress(savedAddress);

                if (customerLatLng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'No valid coordinates found. Please set your location in Profile (tap the location item and save coordinates).'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                // 2) Navigate to MapScreen (note: MapScreen expects `customerLocation:` in your code)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                      customerLocation: customerLatLng,
                      orderTitle: 'Order #${order.id} - Track Delivery',
                    ),
                  ),
                );
              },
              child: const Text('Track Delivery',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kWaterBlue, // ← was Colors.teal
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Delivery'),
                    content: const Text('Have you received your order?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('No')),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Provider.of<OrderProvider>(context, listen: false)
                              .markAsDelivered(order.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Thank you! Order confirmed.'),
                                  backgroundColor:
                                      kWaterBlue)); // ← was Colors.teal
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Confirm Delivery',
                  style: TextStyle(color: Colors.white)),
            ),
          ]),
        ],
      ]),
    );
  }
}
