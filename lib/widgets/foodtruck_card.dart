import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/theme/colors.dart';

class FoodtruckCard extends StatelessWidget {
  const FoodtruckCard({
    super.key,
    required this.foodtruck,
    required this.onTap,
  });

  final FoodTruck foodtruck;
  final VoidCallback onTap;

  Color get _cuisineColor {
    switch (foodtruck.cuisineType?.toLowerCase()) {
      case 'burger':
        return FoodtrackColors.rougeKetchup;
      case 'tacos':
        return FoodtrackColors.vertPickle;
      case 'pizza':
        return FoodtrackColors.jauneMoutarde;
      case 'french':
        return FoodtrackColors.noirBrule;
      case 'crepes':
        return FoodtrackColors.jauneMoutarde;
      case 'falafel':
        return FoodtrackColors.vertPickle;
      case 'asian':
        return FoodtrackColors.rougeKetchup;
      case 'bbq':
        return FoodtrackColors.rougeKetchup;
      default:
        return FoodtrackColors.rougeKetchup;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: FoodtrackColors.noirBrule,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: FoodtrackColors.noirBrule,
              offset: Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: foodtruck.isCurrentlyOpen
                      ? _cuisineColor
                      : FoodtrackColors.noirBrule.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.fastfood,
                  size: 32,
                  color: foodtruck.isCurrentlyOpen
                      ? FoodtrackColors.cremeVintage
                      : FoodtrackColors.noirBrule.withOpacity(0.3),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: FoodtrackColors.noirBrule,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (foodtruck.cuisineType != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: FoodtrackColors.jauneMoutarde,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: FoodtrackColors.noirBrule,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              foodtruck.cuisineType!.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: FoodtrackColors.noirBrule,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: foodtruck.isCurrentlyOpen
                                ? FoodtrackColors.vertPickle
                                : FoodtrackColors.noirBrule.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: FoodtrackColors.noirBrule,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: foodtruck.isCurrentlyOpen
                                    ? FoodtrackColors.cremeVintage
                                    : FoodtrackColors.noirBrule.withOpacity(0.3),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                foodtruck.isCurrentlyOpen ? 'OUVERT' : 'FERME',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: foodtruck.isCurrentlyOpen
                                      ? FoodtrackColors.cremeVintage
                                      : FoodtrackColors.noirBrule.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (foodtruck.getTodayHours() != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Aujourd'hui: ${foodtruck.getTodayHours()}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: FoodtrackColors.noirBrule.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: FoodtrackColors.rougeKetchup.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          foodtruck.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: FoodtrackColors.noirBrule.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: FoodtrackColors.noirBrule.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
