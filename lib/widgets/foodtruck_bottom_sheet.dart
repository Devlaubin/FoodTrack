import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/theme/colors.dart';

void showFoodtruckBottomSheet(BuildContext context, FoodTruck foodtruck) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _FoodtruckBottomSheet(foodtruck: foodtruck),
  );
}

class _FoodtruckBottomSheet extends StatelessWidget {
  const _FoodtruckBottomSheet({required this.foodtruck});

  final FoodTruck foodtruck;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: FoodtrackColors.cremeVintage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: FoodtrackColors.noirBrule, width: 3),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: FoodtrackColors.noirBrule.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: foodtruck.isCurrentlyOpen
                          ? FoodtrackColors.rougeKetchup
                          : FoodtrackColors.noirBrule.withOpacity(0.3),
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
                    child: Icon(
                      Icons.fastfood,
                      size: 32,
                      color: foodtruck.isCurrentlyOpen
                          ? FoodtrackColors.cremeVintage
                          : FoodtrackColors.noirBrule.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodtruck.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: FoodtrackColors.noirBrule,
                          ),
                        ),
                        if (foodtruck.cuisineType != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: FoodtrackColors.jauneMoutarde,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: FoodtrackColors.noirBrule,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              foodtruck.cuisineType!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: FoodtrackColors.noirBrule,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: foodtruck.isCurrentlyOpen
                      ? FoodtrackColors.vertPickle
                      : FoodtrackColors.noirBrule.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      foodtruck.isCurrentlyOpen
                          ? Icons.circle
                          : Icons.circle_outlined,
                      size: 12,
                      color: foodtruck.isCurrentlyOpen
                          ? FoodtrackColors.cremeVintage
                          : FoodtrackColors.noirBrule.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      foodtruck.isCurrentlyOpen ? 'OUVERT' : 'FERME',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: foodtruck.isCurrentlyOpen
                            ? FoodtrackColors.cremeVintage
                            : FoodtrackColors.noirBrule.withOpacity(0.5),
                      ),
                    ),
                    if (foodtruck.getTodayHours() != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${foodtruck.getTodayHours()})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: foodtruck.isCurrentlyOpen
                              ? FoodtrackColors.cremeVintage
                              : FoodtrackColors.noirBrule.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: FoodtrackColors.cremeVintage,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color: FoodtrackColors.rougeKetchup,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      foodtruck.status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: FoodtrackColors.noirBrule,
                      ),
                    ),
                  ],
                ),
              ),

              if (foodtruck.description != null &&
                  foodtruck.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                  child: Text(
                    foodtruck.description!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: FoodtrackColors.noirBrule,
                      height: 1.4,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FoodtrackColors.rougeKetchup,
                        foregroundColor: FoodtrackColors.cremeVintage,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.map),
                      label: const Text(
                        'Itineraire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(
                          AppRouter.foodtruckDetail,
                          arguments: foodtruck,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FoodtrackColors.vertPickle,
                        foregroundColor: FoodtrackColors.cremeVintage,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.restaurant_menu),
                      label: const Text(
                        'Fiche',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
