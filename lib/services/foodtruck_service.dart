import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';

class FoodtruckService extends ChangeNotifier {
  final SupabaseClient _supabase;

  List<FoodTruck> _foodtrucks = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _cuisineTypeFilter;
  bool _openNowFilter = false;
  String _searchQuery = '';

  FoodtruckService(this._supabase) {
    loadFoodtrucks();
  }

  List<FoodTruck> get foodtrucks => _filteredFoodtrucks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get cuisineTypeFilter => _cuisineTypeFilter;
  bool get openNowFilter => _openNowFilter;
  String get searchQuery => _searchQuery;

  List<String> get availableCuisineTypes {
    final types = _foodtrucks
        .map((ft) => ft.cuisineType)
        .whereType<String>()
        .toSet()
        .toList();
    types.sort();
    return types;
  }

  List<FoodTruck> get _filteredFoodtrucks {
    var filtered = _foodtrucks;

    if (_cuisineTypeFilter != null && _cuisineTypeFilter!.isNotEmpty) {
      filtered = filtered
          .where((ft) => ft.cuisineType == _cuisineTypeFilter)
          .toList();
    }

    if (_openNowFilter) {
      filtered = filtered.where((ft) => ft.isCurrentlyOpen).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((ft) {
        return ft.name.toLowerCase().contains(query) ||
            ft.status.toLowerCase().contains(query) ||
            (ft.cuisineType?.toLowerCase().contains(query) ?? false) ||
            (ft.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  Future<void> loadFoodtrucks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('foodtrucks')
          .select()
          .order('name');

      _foodtrucks = response
          .map<FoodTruck>((json) => FoodTruck.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading foodtrucks: $e');
      _error = 'Impossible de charger les foodtrucks';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCuisineTypeFilter(String? cuisineType) {
    _cuisineTypeFilter = cuisineType;
    notifyListeners();
  }

  void setOpenNowFilter(bool value) {
    _openNowFilter = value;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearFilters() {
    _cuisineTypeFilter = null;
    _openNowFilter = false;
    _searchQuery = '';
    notifyListeners();
  }

  FoodTruck? getById(String id) {
    try {
      return _foodtrucks.firstWhere((ft) => ft.id == id);
    } catch (_) {
      return null;
    }
  }
}
