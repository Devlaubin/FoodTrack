import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/domain/foodtruck_icons.dart';

/// Sort options available in the filter panel.
enum FoodtruckSort { relevance, name, distance, openFirst }

class FoodtruckService extends ChangeNotifier {
  final SupabaseClient _supabase;

  List<FoodTruck> _foodtrucks = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  final Set<String> _cuisineTypeFilters = {};
  bool _openNowFilter = false;
  String _searchQuery = '';
  double? _distanceKm;
  double? _userLat;
  double? _userLng;
  double? _userHeading;
  bool _isLocating = false;
  String? _locationError;
  FoodtruckSort _sortOption = FoodtruckSort.relevance;

  StreamSubscription<Position>? _positionStreamSubscription;

  FoodtruckService(this._supabase) {
    loadFoodtrucks();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  List<FoodTruck> get foodtrucks => _filteredFoodtrucks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get cuisineTypeFilters => Set.unmodifiable(_cuisineTypeFilters);
  bool get openNowFilter => _openNowFilter;
  String get searchQuery => _searchQuery;
  double? get distanceKm => _distanceKm;
  bool get isLocating => _isLocating;
  String? get locationError => _locationError;
  FoodtruckSort get sortOption => _sortOption;

  bool get hasUserLocation => _userLat != null && _userLng != null;

  /// The user's current position (when location is active).
  LatLng? get userPosition =>
      hasUserLocation ? LatLng(_userLat!, _userLng!) : null;

  /// The user's current heading in degrees (0-360, 0 = north).
  /// Null when heading is not available.
  double? get userHeading => _userHeading;

  /// Distance in km between the user and the given foodtruck.
  /// Returns null when the user location is not available.
  double? distanceToFoodtruck(FoodTruck foodtruck) {
    final pos = userPosition;
    if (pos == null) return null;
    return const Distance().as(LengthUnit.Kilometer, pos, foodtruck.position);
  }

  /// True when any filter (search, cuisine, open-now, distance) is applied.
  bool get hasActiveFilters {
    return _cuisineTypeFilters.isNotEmpty ||
        _openNowFilter ||
        _searchQuery.trim().isNotEmpty ||
        _distanceKm != null;
  }

  /// Counts the number of active filter categories (max 4).
  int get activeFilterCount {
    var count = 0;
    if (_cuisineTypeFilters.isNotEmpty) count++;
    if (_openNowFilter) count++;
    if (_searchQuery.trim().isNotEmpty) count++;
    if (_distanceKm != null) count++;
    return count;
  }

  List<String> get availableCuisineTypes {
    final types = <String>{};
    for (final ft in _foodtrucks) {
      types.addAll(parseCuisineTypes(ft.cuisineType));
    }
    final sorted = types.toList()..sort();
    return sorted;
  }

  List<FoodTruck> get _filteredFoodtrucks {
    var filtered = _foodtrucks;

    // Multi-select cuisine filter
    if (_cuisineTypeFilters.isNotEmpty) {
      filtered = filtered.where((ft) {
        final ftTypes = parseCuisineTypes(ft.cuisineType).toSet();
        if (ftTypes.isEmpty) return false;
        return ftTypes.any(_cuisineTypeFilters.contains);
      }).toList();
    }

    // Open now filter
    if (_openNowFilter) {
      filtered = filtered.where((ft) => ft.isCurrentlyOpen).toList();
    }

    // Search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((ft) {
        return ft.name.toLowerCase().contains(query) ||
            ft.status.toLowerCase().contains(query) ||
            (ft.cuisineType?.toLowerCase().contains(query) ?? false) ||
            (ft.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Distance filter ("près de moi")
    if (_distanceKm != null && hasUserLocation) {
      final userPoint = LatLng(_userLat!, _userLng!);
      filtered = filtered.where((ft) {
        final km = const Distance().as(
          LengthUnit.Kilometer,
          userPoint,
          ft.position,
        );
        return km <= _distanceKm!;
      }).toList();
    }

    // Sorting
    final sorted = [...filtered];
    switch (_sortOption) {
      case FoodtruckSort.name:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case FoodtruckSort.distance:
        if (hasUserLocation) {
          final userPoint = LatLng(_userLat!, _userLng!);
          sorted.sort((a, b) {
            final da = const Distance().as(
              LengthUnit.Kilometer,
              userPoint,
              a.position,
            );
            final db = const Distance().as(
              LengthUnit.Kilometer,
              userPoint,
              b.position,
            );
            return da.compareTo(db);
          });
        }
        break;
      case FoodtruckSort.openFirst:
        sorted.sort((a, b) {
          if (a.isCurrentlyOpen == b.isCurrentlyOpen) return 0;
          return a.isCurrentlyOpen ? -1 : 1;
        });
        break;
      case FoodtruckSort.relevance:
        break;
    }

    return sorted;
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

  /// Toggles a cuisine type in the multi-select set.
  void toggleCuisineTypeFilter(String cuisineType) {
    if (!_cuisineTypeFilters.remove(cuisineType)) {
      _cuisineTypeFilters.add(cuisineType);
    }
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

  /// Sets or removes the distance radius filter.
  /// When [km] is null the distance filter is disabled.
  void setDistanceKm(double? km) {
    _distanceKm = km;
    notifyListeners();
  }

  void setSortOption(FoodtruckSort option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Requests the user's GPS location (lazily) to enable the
  /// distance filter. No permission dialog is shown unless needed.
  Future<bool> requestLocation() async {
    _isLocating = true;
    _locationError = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Active la localisation pour utiliser "près de moi".';
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _locationError = 'Permission de localisation refusée.';
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Autorise la localisation dans les réglages.';
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      _userLat = position.latitude;
      _userLng = position.longitude;
      _userHeading = position.heading;

      // Start tracking live position + heading.
      _startPositionStream();
      return true;
    } catch (e) {
      debugPrint('Error getting location: $e');
      _locationError = 'Impossible de récupérer ta position.';
      return false;
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  /// Starts a live stream of the user position + heading so the map
  /// arrow stays in sync with the device's direction.
  void _startPositionStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen(
          (position) {
            _userLat = position.latitude;
            _userLng = position.longitude;
            if (position.heading >= 0) {
              _userHeading = position.heading;
            }
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Position stream error: $e');
          },
        );
  }

  /// Stops the live position stream and clears the cached location.
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _userLat = null;
    _userLng = null;
    _userHeading = null;
    _distanceKm = null;
    _locationError = null;
    notifyListeners();
  }

  /// Removes the cached user location and distance filter.
  void clearLocation() {
    stopLocationUpdates();
  }

  void clearFilters() {
    _cuisineTypeFilters.clear();
    _openNowFilter = false;
    _searchQuery = '';
    stopLocationUpdates();
    _sortOption = FoodtruckSort.relevance;
    notifyListeners();
  }

  FoodTruck? getById(String id) {
    try {
      return _foodtrucks.firstWhere((ft) => ft.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Re-fetches a single foodtruck from the server (used after a review is
  /// submitted so the rating badge updates everywhere).
  Future<void> refreshFoodtruck(String id) async {
    try {
      final response = await _supabase
          .from('foodtrucks')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response != null) {
        final refreshed = FoodTruck.fromJson(response);
        final index = _foodtrucks.indexWhere((ft) => ft.id == id);
        if (index != -1) {
          _foodtrucks[index] = refreshed;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error refreshing foodtruck: $e');
    }
  }
}
