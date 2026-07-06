class MenuItem {
  const MenuItem({
    required this.id,
    required this.foodtruckId,
    required this.name,
    required this.price,
    this.description,
    this.category,
    this.isAvailable = true,
    this.imageUrl,
  });

  final String id;
  final String foodtruckId;
  final String name;
  final double price;
  final String? description;
  final String? category;
  final bool isAvailable;
  final String? imageUrl;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      foodtruckId: json['foodtruck_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      category: json['category'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodtruck_id': foodtruckId,
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'is_available': isAvailable,
      'image_url': imageUrl,
    };
  }

  String get priceFormatted => '${price.toStringAsFixed(2)} EUR';
}
