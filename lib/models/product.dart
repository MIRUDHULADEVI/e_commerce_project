class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final double? originalPrice; // Add this line

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.originalPrice, // Add this line
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageUrl: json['imageUrl'] ?? '',
      originalPrice: json['originalPrice'] != null ? (json['originalPrice'] as num).toDouble() : null, // Add this line
    );
  }
}
