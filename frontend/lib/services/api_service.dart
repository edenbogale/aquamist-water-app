import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/water_item.dart';

class ApiService {
  // ✅ FIXED: Changed to just the directory path
  static const String baseUrl =
      'http://localhost:8080/water_api/getProducts.php';

  Future<Map<String, List<WaterItem>>> fetchProductsGroupedByCategory() async {
    // ✅ FIXED: Now this creates the correct URL
    final response = await http.get(Uri.parse('$baseUrl/getProducts.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> productsJson = data['data'];
        Map<String, List<WaterItem>> categories = {};

        for (var json in productsJson) {
          WaterItem item = WaterItem.fromJson(json);
          String cat = item.category;

          if (!categories.containsKey(cat)) {
            categories[cat] = [];
          }
          categories[cat]?.add(item);
        }

        // Sort items in each category by name
        categories.forEach((key, list) {
          list.sort((a, b) => a.name.compareTo(b.name));
        });

        return categories;
      } else {
        throw Exception(
            'Failed to load products: ${data['error'] ?? 'Unknown'}');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }
}
