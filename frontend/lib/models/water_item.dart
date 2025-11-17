class WaterItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double? rating;
  final int? comments;
  final String? distance;
  final String? deliveryTime;

  WaterItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating,
    this.comments,
    this.distance,
    this.deliveryTime,
  });

  // ✅ Factory to create from JSON (from backend)
  factory WaterItem.fromJson(Map<String, dynamic> json) {
    String rawImage = (json['image_url'] ?? '').toString();

    // If backend gives a full URL, use it. Otherwise, prepend base URL.
    String fixedImage = rawImage.startsWith("http")
        ? rawImage
        : "http://localhost:8080/water_api/" + rawImage;

    // Debugging (check console)
    print("Raw image_url: $rawImage");
    print("Fixed image_url: $fixedImage");

    return WaterItem(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl: fixedImage,
      category: json['category'] ?? '',
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      comments: json['comments'] != null
          ? int.tryParse(json['comments'].toString())
          : null,
      distance: json['distance'],
      deliveryTime: json['delivery_time'],
    );
  }

  // ✅ Optional: Convert back to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'category': category,
        'rating': rating,
        'comments': comments,
        'distance': distance,
        'deliveryTime': deliveryTime,
      };
}
