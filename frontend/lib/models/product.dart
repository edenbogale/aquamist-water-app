class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int comments;
  final double distance;
  final String deliveryTime;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.comments,
    required this.distance,
    required this.deliveryTime,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['id'].toString()),
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      category: json['category'],
      rating: double.parse(json['rating'].toString()),
      comments: int.parse(json['comments'].toString()),
      distance: double.parse(json['distance'].toString()),
      deliveryTime: json['delivery_time'],
    );
  }
}
