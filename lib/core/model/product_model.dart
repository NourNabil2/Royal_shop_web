// Product Model
class Product {
  final String id;
  final String name;
  final List<String> imageUrls;
  final double price;
  final String description;
  final String shortDescription;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.price,
    required this.description,
    required this.shortDescription,
    required this.category,
  });

  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';
}