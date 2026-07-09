import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/domain/menu_item.dart';

/// Handles everything a "Pro" (foodtruck owner) account needs:
/// managing their own foodtruck record, its menu, and its live position.
class ProService extends ChangeNotifier {
  ProService(this._supabase);

  final SupabaseClient _supabase;

  FoodTruck? _myFoodtruck;
  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  bool _isUpdatingPosition = false;

  FoodTruck? get myFoodtruck => _myFoodtruck;
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUpdatingPosition => _isUpdatingPosition;

  Future<void> loadMyFoodtruck(String ownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('foodtrucks')
          .select()
          .eq('owner_id', ownerId)
          .maybeSingle();

      _myFoodtruck = response != null ? FoodTruck.fromJson(response) : null;

      if (_myFoodtruck != null) {
        await loadMenuItems();
      }
    } catch (e) {
      debugPrint('Error loading pro foodtruck: $e');
      _error = 'Impossible de charger ton foodtruck';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMyFoodtruck({
    required String ownerId,
    required String name,
    String? cuisineType,
    String? description,
    double latitude = 48.8566,
    double longitude = 2.3522,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('foodtrucks')
          .insert({
            'owner_id': ownerId,
            'name': name,
            'cuisine_type': cuisineType,
            'description': description,
            'latitude': latitude,
            'longitude': longitude,
            'is_open': true,
            'status': 'Ouvert',
          })
          .select()
          .single();

      _myFoodtruck = FoodTruck.fromJson(response);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating foodtruck: $e');
      _error = 'Impossible de creer ton foodtruck';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateInfo({
    String? name,
    String? description,
    String? cuisineType,
    String? imageUrl,
    bool? isOpen,
    String? status,
  }) async {
    if (_myFoodtruck == null) return false;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (cuisineType != null) updates['cuisine_type'] = cuisineType;
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (isOpen != null) updates['is_open'] = isOpen;
    if (status != null) updates['status'] = status;

    if (updates.isEmpty) return true;

    try {
      final response = await _supabase
          .from('foodtrucks')
          .update(updates)
          .eq('id', _myFoodtruck!.id)
          .select()
          .single();

      _myFoodtruck = FoodTruck.fromJson(response);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating foodtruck info: $e');
      _error = 'Impossible de mettre a jour les infos';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOpeningHours(Map<String, DayHours> hours) async {
    if (_myFoodtruck == null) return false;

    try {
      final response = await _supabase
          .from('foodtrucks')
          .update({
            'opening_hours': hours.map(
              (key, value) => MapEntry(key, value.toJson()),
            ),
          })
          .eq('id', _myFoodtruck!.id)
          .select()
          .single();

      _myFoodtruck = FoodTruck.fromJson(response);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating opening hours: $e');
      _error = 'Impossible de mettre a jour les horaires';
      notifyListeners();
      return false;
    }
  }

  /// Reads the device/browser GPS position and pushes it as the foodtruck's
  /// live location, so it moves on the map in (near) real time.
  Future<String?> updateLivePosition() async {
    if (_myFoodtruck == null) return 'Cree d\'abord ton foodtruck';

    _isUpdatingPosition = true;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Active la localisation pour partager ta position';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Permission de localisation refusee';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return 'Autorise la localisation dans les parametres du navigateur';
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final response = await _supabase
          .from('foodtrucks')
          .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
          })
          .eq('id', _myFoodtruck!.id)
          .select()
          .single();

      _myFoodtruck = FoodTruck.fromJson(response);
      return null;
    } catch (e) {
      debugPrint('Error updating live position: $e');
      return 'Impossible de recuperer ta position';
    } finally {
      _isUpdatingPosition = false;
      notifyListeners();
    }
  }

  Future<void> loadMenuItems() async {
    if (_myFoodtruck == null) return;

    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('foodtruck_id', _myFoodtruck!.id)
          .order('category')
          .order('name');

      _menuItems =
          response.map<MenuItem>((json) => MenuItem.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading menu items: $e');
      _error = 'Impossible de charger le menu';
      notifyListeners();
    }
  }

  Future<bool> addMenuItem({
    required String name,
    required double price,
    String? description,
    String? category,
  }) async {
    if (_myFoodtruck == null) return false;

    try {
      await _supabase.from('menu_items').insert({
        'foodtruck_id': _myFoodtruck!.id,
        'name': name,
        'price': price,
        'description': description,
        'category': category ?? 'plat',
      });
      await loadMenuItems();
      return true;
    } catch (e) {
      debugPrint('Error adding menu item: $e');
      _error = 'Impossible d\'ajouter cet article';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMenuItem(
    String id, {
    String? name,
    double? price,
    String? description,
    String? category,
    bool? isAvailable,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (description != null) updates['description'] = description;
    if (category != null) updates['category'] = category;
    if (isAvailable != null) updates['is_available'] = isAvailable;

    if (updates.isEmpty) return true;

    try {
      await _supabase.from('menu_items').update(updates).eq('id', id);
      await loadMenuItems();
      return true;
    } catch (e) {
      debugPrint('Error updating menu item: $e');
      _error = 'Impossible de mettre a jour cet article';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMenuItem(String id) async {
    try {
      await _supabase.from('menu_items').delete().eq('id', id);
      _menuItems.removeWhere((item) => item.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      _error = 'Impossible de supprimer cet article';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Resets all cached Pro data. Must be called on sign-out/account switch
  /// so a different account never briefly renders the previous owner's
  /// foodtruck or menu.
  void clear() {
    _myFoodtruck = null;
    _menuItems = [];
    _isLoading = false;
    _error = null;
    _isUpdatingPosition = false;
    notifyListeners();
  }
}
