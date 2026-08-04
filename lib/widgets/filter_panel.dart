import 'package:flutter/material.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key, this.showSearch = true});

  final bool showSearch;

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final service = context.read<FoodtruckService>();
    _searchController = TextEditingController(text: service.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onDistanceSelected(FoodtruckService service, double? km) async {
    // Selecting a radius requires a location. If we already have one, just apply.
    if (km != null && !service.hasUserLocation) {
      final success = await service.requestLocation();
      if (!success) return; // Location error is shown in the panel
    }
    service.setDistanceKm(km);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodtruckService>(
      builder: (context, service, child) {
        if (_searchController.text != service.searchQuery) {
          _searchController.value = _searchController.value.copyWith(
            text: service.searchQuery,
            selection: TextSelection.collapsed(
              offset: service.searchQuery.length,
            ),
          );
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: FoodtrackColors.rougeKetchup,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const Spacer(),
                  if (service.hasActiveFilters)
                    TextButton(
                      onPressed: service.clearFilters,
                      style: TextButton.styleFrom(
                        foregroundColor: FoodtrackColors.rougeKetchup,
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              if (widget.showSearch) ...[
                const SizedBox(height: 12),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: FoodtrackColors.cremeVintage,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: FoodtrackColors.noirBrule,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    onChanged: service.setSearchQuery,
                    controller: _searchController,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: FoodtrackColors.noirBrule,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nom ou type de cuisine...',
                      hintStyle: TextStyle(
                        color: FoodtrackColors.noirBrule.withOpacity(0.4),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: FoodtrackColors.rougeKetchup,
                      ),
                      suffixIcon: service.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: FoodtrackColors.noirBrule,
                              ),
                              onPressed: () => service.setSearchQuery(''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Open now filter
              GestureDetector(
                onTap: () {
                  service.setOpenNowFilter(!service.openNowFilter);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: service.openNowFilter
                        ? FoodtrackColors.vertPickle
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FoodtrackColors.noirBrule,
                      width: service.openNowFilter ? 3 : 2,
                    ),
                    boxShadow: service.openNowFilter
                        ? const [
                            BoxShadow(
                              color: FoodtrackColors.noirBrule,
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: service.openNowFilter
                            ? FoodtrackColors.cremeVintage
                            : FoodtrackColors.noirBrule.withOpacity(0.5),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ouverts maintenant',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: service.openNowFilter
                              ? FoodtrackColors.cremeVintage
                              : FoodtrackColors.noirBrule,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (service.availableCuisineTypes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Type de cuisine',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: FoodtrackColors.noirBrule,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: service.availableCuisineTypes.map((type) {
                    final isSelected = service.cuisineTypeFilters.contains(type);
                    return GestureDetector(
                      onTap: () {
                        service.toggleCuisineTypeFilter(type);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? FoodtrackColors.jauneMoutarde
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FoodtrackColors.noirBrule,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: isSelected
                              ? const [
                                  BoxShadow(
                                    color: FoodtrackColors.noirBrule,
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(
                                Icons.check,
                                size: 14,
                                color: FoodtrackColors.noirBrule,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? FoodtrackColors.noirBrule
                                    : FoodtrackColors.noirBrule.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Distance filter ("Près de moi")
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.near_me,
                    color: FoodtrackColors.rougeKetchup,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Près de moi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                  const Spacer(),
                  if (service.distanceKm != null)
                    GestureDetector(
                      onTap: () => service.clearLocation(),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: FoodtrackColors.rougeKetchup,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [1, 5, 10, 25, 50].map((km) {
                  final isSelected = service.distanceKm == km;
                  return GestureDetector(
                    onTap: service.isLocating
                        ? null
                        : () => _onDistanceSelected(service, km.toDouble()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? FoodtrackColors.vertPickle
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FoodtrackColors.noirBrule,
                          width: isSelected ? 3 : 2,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                  color: FoodtrackColors.noirBrule,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        '$km km',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? FoodtrackColors.cremeVintage
                              : FoodtrackColors.noirBrule.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (service.isLocating) ...[
                const SizedBox(height: 8),
                const Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FoodtrackColors.rougeKetchup,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Localisation...',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: FoodtrackColors.noirBrule,
                      ),
                    ),
                  ],
                ),
              ],
              if (service.locationError != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 14,
                      color: FoodtrackColors.rougeKetchup,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        service.locationError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: FoodtrackColors.rougeKetchup,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Sort section
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(
                    Icons.sort,
                    color: FoodtrackColors.rougeKetchup,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Trier par',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SortChip(
                    label: 'Pertinence',
                    icon: Icons.auto_awesome,
                    isSelected: service.sortOption == FoodtruckSort.relevance,
                    onTap: () => service.setSortOption(FoodtruckSort.relevance),
                  ),
                  _SortChip(
                    label: 'Nom (A-Z)',
                    icon: Icons.sort_by_alpha,
                    isSelected: service.sortOption == FoodtruckSort.name,
                    onTap: () => service.setSortOption(FoodtruckSort.name),
                  ),
                  _SortChip(
                    label: 'Distance',
                    icon: Icons.near_me,
                    isSelected: service.sortOption == FoodtruckSort.distance,
                    onTap: () async {
                      if (!service.hasUserLocation) {
                        await service.requestLocation();
                      }
                      service.setSortOption(FoodtruckSort.distance);
                    },
                  ),
                  _SortChip(
                    label: 'Ouverts d\'abord',
                    icon: Icons.bolt,
                    isSelected: service.sortOption == FoodtruckSort.openFirst,
                    onTap: () =>
                        service.setSortOption(FoodtruckSort.openFirst),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? FoodtrackColors.jauneMoutarde : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FoodtrackColors.noirBrule,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: FoodtrackColors.noirBrule,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? FoodtrackColors.noirBrule
                  : FoodtrackColors.noirBrule.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? FoodtrackColors.noirBrule
                    : FoodtrackColors.noirBrule.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

