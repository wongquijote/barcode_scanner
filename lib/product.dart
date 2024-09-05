import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String? image;
  final double price;
  final double weight;
  final double? rating;
  final Uint8List? nutritionImage;
  final Uint8List? locationImage;
  final bool active;

  Product({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    required this.weight,
    this.rating,
    this.nutritionImage,
    this.locationImage,
    required this.active,
  });

  // Factory constructor to create a Product from a Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      price: map['price'],
      weight: map['weight'],
      rating: map['rating'],
      nutritionImage: map['nutrition_image'],
      locationImage: map['location_image'],
      active: map['active'] == 1,  // SQLite stores booleans as integers (0 or 1)
    );
  }

  // Method to convert a Product to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'weight': weight,
      'rating': rating,
      'nutrition_image': nutritionImage,
      'location_image': locationImage,
      'active': active ? 1 : 0,  // Convert boolean to integer (1 or 0)
    };
  }
}
