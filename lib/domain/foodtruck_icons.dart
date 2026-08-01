import 'package:flutter/material.dart';

class FoodtruckIcon {
  final String id;
  final IconData icon;
  final String label;

  const FoodtruckIcon({
    required this.id,
    required this.icon,
    required this.label,
  });
}

/// Curated list of food-related icons that foodtruck owners can choose from
/// as their logo displayed on the map card, bottom sheet, and detail banner.
const List<FoodtruckIcon> foodtruckIcons = [
  FoodtruckIcon(id: 'fastfood', icon: Icons.fastfood, label: 'Fast Food'),
  FoodtruckIcon(id: 'restaurant', icon: Icons.restaurant, label: 'Restaurant'),
  FoodtruckIcon(
    id: 'restaurant_menu',
    icon: Icons.restaurant_menu,
    label: 'Menu',
  ),
  FoodtruckIcon(
    id: 'lunch_dining',
    icon: Icons.lunch_dining,
    label: 'Déjeuner',
  ),
  FoodtruckIcon(id: 'dinner_dining', icon: Icons.dinner_dining, label: 'Dîner'),
  FoodtruckIcon(id: 'local_pizza', icon: Icons.local_pizza, label: 'Pizza'),
  FoodtruckIcon(id: 'ramen_dining', icon: Icons.ramen_dining, label: 'Ramen'),
  FoodtruckIcon(id: 'set_meal', icon: Icons.set_meal, label: 'Repas'),
  FoodtruckIcon(id: 'tapas', icon: Icons.tapas, label: 'Tapas'),
  FoodtruckIcon(
    id: 'bakery_dining',
    icon: Icons.bakery_dining,
    label: 'Boulangerie',
  ),
  FoodtruckIcon(id: 'icecream', icon: Icons.icecream, label: 'Glace'),
  FoodtruckIcon(id: 'egg', icon: Icons.egg, label: 'Œuf'),
  FoodtruckIcon(id: 'egg_alt', icon: Icons.egg_alt, label: 'Œuf Alt'),
  FoodtruckIcon(id: 'kebab_dining', icon: Icons.kebab_dining, label: 'Kebab'),
  FoodtruckIcon(
    id: 'brunch_dining',
    icon: Icons.brunch_dining,
    label: 'Brunch',
  ),
  FoodtruckIcon(id: 'coffee', icon: Icons.coffee, label: 'Café'),
  FoodtruckIcon(id: 'local_cafe', icon: Icons.local_cafe, label: 'Café'),
  FoodtruckIcon(id: 'soup_kitchen', icon: Icons.soup_kitchen, label: 'Soupe'),
  FoodtruckIcon(id: 'flatware', icon: Icons.flatware, label: 'Couvert'),
  FoodtruckIcon(id: 'rice_bowl', icon: Icons.rice_bowl, label: 'Riz'),
];

/// Resolves a stored icon ID string to its IconData.
/// Returns [Icons.fastfood] as fallback if the ID is unknown or null.
IconData resolveIcon(String? iconId) {
  if (iconId == null) return Icons.fastfood;
  final match = foodtruckIcons.where((f) => f.id == iconId);
  return match.isNotEmpty ? match.first.icon : Icons.fastfood;
}
