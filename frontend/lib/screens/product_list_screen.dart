import 'package:flutter/material.dart';

// 💧 Define water blue — ONLY addition to your code
const Color kWaterBlue = Color(0xFF2196F3);

class ProductListScreen extends StatelessWidget {
  final String type;
  final String categoryName;

  const ProductListScreen({required this.type, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final products = getProducts(type);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: kWaterBlue, // ← was Colors.teal
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, index) {
          final p = products[index];
          return ListTile(
            leading:
                Icon(Icons.local_drink, color: kWaterBlue), // ← was Colors.teal
            title: Text('${p['name']} - ${p['size']}'),
            subtitle: Text('KES ${p['price']}'),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> getProducts(String type) {
    if (type == 'sparkling') {
      return [
        {'name': 'Sparkling Water', 'size': '500ml', 'price': 60},
        {'name': 'Sparkling Water', 'size': '1L', 'price': 100},
      ];
    } else if (type == 'mineral') {
      return [
        {'name': 'Mineral Water', 'size': '300ml', 'price': 40},
        {'name': 'Mineral Water', 'size': '500ml', 'price': 70},
      ];
    } else if (type == 'still') {
      return [
        {'name': 'Still Water', 'size': '500ml', 'price': 50},
        {'name': 'Still Water', 'size': '1L', 'price': 80},
      ];
    } else if (type == 'juice') {
      return [
        {'name': 'Mango Juice', 'size': '300ml', 'price': 60},
        {'name': 'Orange Juice', 'size': '300ml', 'price': 60},
      ];
    } else {
      return [];
    }
  }
}
