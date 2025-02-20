class Product {
  final String id;
  final String brand;
  final String color;
  final String image;
  final String material;
  final String name;
  final double price;
  final double rating;
  final Map<String, bool> sizes;
  final int stock;
  final String type;
  final String collection;
  final String description;

  Product({
    required this.id,
    required this.brand,
    required this.color,
    required this.image,
    required this.material,
    required this.name,
    required this.price,
    required this.rating,
    required this.sizes,
    required this.stock,
    required this.type,
    required this.collection,
    required this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['_id'] ?? '',
      brand: map['brand'] ?? '',
      color: map['color'] ?? '',
      image: map['image'] ?? '',
      material: map['material'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0).toDouble(),
      sizes: Map<String, bool>.from(map['sizes'] ?? {}),
      stock: map['stock'] ?? 0,
      type: map['type'] ?? '',
      collection: map['collection'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'brand': brand,
      'color': color,
      'image': image,
      'material': material,
      'name': name,
      'price': price,
      'rating': rating,
      'sizes': sizes,
      'stock': stock,
      'type': type,
      'collection': collection,
      'description': description,
    };
  }
}
