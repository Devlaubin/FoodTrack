import 'package:flutter/material.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key});

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
                  if (service.cuisineTypeFilter != null ||
                      service.openNowFilter)
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
                    final isSelected = service.cuisineTypeFilter == type;
                    return GestureDetector(
                      onTap: () {
                        service.setCuisineTypeFilter(
                          isSelected ? null : type,
                        );
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
                        child: Text(
                          type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? FoodtrackColors.noirBrule
                                : FoodtrackColors.noirBrule.withOpacity(0.7),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
