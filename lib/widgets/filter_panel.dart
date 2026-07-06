import 'package:flutter/material.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class FilterPanel extends StatelessWidget {
  const FilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodtruckService>(
      builder: (context, service, child) {
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
