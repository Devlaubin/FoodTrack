class FoodTruck {
  const FoodTruck({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisineType,
    required this.isOpen,
    required this.status,
  });

  final String id;
  final String name;
  final String description;
  final String cuisineType;
  final bool isOpen;
  final String status;
}
