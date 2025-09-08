// Product Model
class Product {
  final String id;
  final String name;
  final List<String> imageUrls;
  final double price;
  final String description;
  final String? dimensions;
  final String shortDescription;
  final String category;
  final String matrial;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.price,
    this.dimensions,
    required this.description,
    required this.matrial,
    required this.shortDescription,
    required this.inStock,
    required this.category,
  });

  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}