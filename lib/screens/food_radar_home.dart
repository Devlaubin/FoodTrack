import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:foodtruck_app/widgets/filter_panel.dart';
import 'package:foodtruck_app/widgets/foodtruck_bottom_sheet.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class FoodRadarHome extends StatefulWidget {
  const FoodRadarHome({super.key});

  @override
  State<FoodRadarHome> createState() => _FoodRadarHomeState();
}

class _FoodRadarHomeState extends State<FoodRadarHome> {
  bool _showFilters = false;
  final MapController _mapController = MapController();
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, FoodtruckService>(
      builder: (context, auth, foodtruckService, child) {
        // Sync search controller with service
        if (_searchController.text != foodtruckService.searchQuery) {
          _searchController.value = _searchController.value.copyWith(
            text: foodtruckService.searchQuery,
            selection: TextSelection.collapsed(
              offset: foodtruckService.searchQuery.length,
            ),
          );
        }

        return Scaffold(
          backgroundColor: FoodtrackColors.cremeVintage,
          body: Stack(
            children: [
              // Full-screen map
              Positioned.fill(
                child: _buildMap(context, auth, foodtruckService),
              ),

              // Top overlay with logo, search, and filters
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              FoodtrackColors.cremeVintage.withOpacity(0.95),
                              FoodtrackColors.cremeVintage.withOpacity(0.0),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            // Logo top-left
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(
                                'assets/Logo.png',
                                width: 64,
                                height: 64,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Search bar (expanded)
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: FoodtrackColors.noirBrule,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: FoodtrackColors.noirBrule,
                                      offset: Offset(3, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  onChanged: foodtruckService.setSearchQuery,
                                  controller: _searchController,
                                  textAlignVertical: TextAlignVertical.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: FoodtrackColors.noirBrule,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Rechercher un foodtruck...',
                                    hintStyle: TextStyle(
                                      color: FoodtrackColors.noirBrule
                                          .withOpacity(0.4),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(
                                        left: 12,
                                        right: 8,
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        color: FoodtrackColors.rougeKetchup,
                                        size: 20,
                                      ),
                                    ),
                                    suffixIcon:
                                        foodtruckService.searchQuery.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color:
                                                    FoodtrackColors.noirBrule,
                                                size: 18,
                                              ),
                                              onPressed: () => foodtruckService
                                                  .setSearchQuery(''),
                                            ),
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Filter toggle button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showFilters = !_showFilters;
                                });
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _showFilters
                                      ? FoodtrackColors.rougeKetchup
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: FoodtrackColors.noirBrule,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: FoodtrackColors.noirBrule,
                                      offset: Offset(3, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.filter_list,
                                        color: _showFilters
                                            ? FoodtrackColors.cremeVintage
                                            : FoodtrackColors.noirBrule,
                                      ),
                                    ),
                                    if (foodtruckService.cuisineTypeFilter !=
                                            null ||
                                        foodtruckService.openNowFilter)
                                      Positioned(
                                        top: -2,
                                        right: -2,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: FoodtrackColors.vertPickle,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  FoodtrackColors.cremeVintage,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filter panel
                    if (_showFilters)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Material(
                            elevation: 6,
                            color: Colors.transparent,
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.45,
                              ),
                              child: SingleChildScrollView(
                                child: FilterPanel(showSearch: false),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Truck count badge (bottom-left)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: FoodtrackColors.cremeVintage,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: FoodtrackColors.noirBrule,
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: FoodtrackColors.noirBrule,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fastfood,
                        size: 16,
                        color: FoodtrackColors.rougeKetchup,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${foodtruckService.foodtrucks.length} trucks',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: FoodtrackColors.noirBrule,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Removed: list and logout buttons (top-right corner)
              // The list button is now available via the bottom navigation bar (HomeShell),
              // and logout via the Profile screen.
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap(
    BuildContext context,
    AuthService auth,
    FoodtruckService foodtruckService,
  ) {
    if (foodtruckService.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: FoodtrackColors.rougeKetchup),
      );
    }

    if (foodtruckService.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: FoodtrackColors.rougeKetchup,
            ),
            const SizedBox(height: 16),
            Text(
              foodtruckService.error!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FoodtrackColors.noirBrule,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: foodtruckService.loadFoodtrucks,
              style: ElevatedButton.styleFrom(
                backgroundColor: FoodtrackColors.rougeKetchup,
                foregroundColor: FoodtrackColors.cremeVintage,
              ),
              child: const Text('Reessayer'),
            ),
          ],
        ),
      );
    }

    if (foodtruckService.foodtrucks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fastfood_outlined,
              size: 64,
              color: FoodtrackColors.noirBrule.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun foodtruck trouve',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: FoodtrackColors.noirBrule,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essaie d\'elargir tes filtres',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: FoodtrackColors.noirBrule,
              ),
            ),
          ],
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: foodtruckService.foodtrucks.isNotEmpty
            ? foodtruckService.foodtrucks.first.position
            : const LatLng(48.8566, 2.3522),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.foodtrack.app',
          maxZoom: 19,
          errorTileCallback: (tile, error, stackTrace) {},
        ),
        MarkerLayer(
          markers: foodtruckService.foodtrucks
              .map(
                (foodtruck) => Marker(
                  point: foodtruck.position,
                  width: 72,
                  height: 72,
                  child: FoodtruckMapMarker(
                    foodtruck: foodtruck,
                    onTap: () {
                      showFoodtruckBottomSheet(context, foodtruck);
                    },
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class FoodtruckMapMarker extends StatelessWidget {
  const FoodtruckMapMarker({
    super.key,
    required this.foodtruck,
    required this.onTap,
  });

  final FoodTruck foodtruck;
  final VoidCallback onTap;

  Color get _markerColor {
    if (!foodtruck.isCurrentlyOpen) {
      return FoodtrackColors.noirBrule.withOpacity(0.6);
    }
    switch (foodtruck.cuisineType?.toLowerCase()) {
      case 'burger':
        return FoodtrackColors.rougeKetchup;
      case 'tacos':
        return FoodtrackColors.vertPickle;
      case 'pizza':
        return FoodtrackColors.jauneMoutarde;
      default:
        return FoodtrackColors.rougeKetchup;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _markerColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FoodtrackColors.noirBrule, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: FoodtrackColors.noirBrule,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          foodtruck.logoIcon,
          size: 26,
          color: FoodtrackColors.cremeVintage,
        ),
      ),
    );
  }
}
