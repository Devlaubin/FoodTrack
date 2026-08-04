import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:foodtruck_app/utils/formatters.dart';
import 'package:foodtruck_app/widgets/star_rating.dart';
import 'package:provider/provider.dart';

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

  Color get _accentColor {
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

  /// Formats a distance in km nicely: "850 m" under 1 km, otherwise "1,2 km".
  String _formatDistance(double km) {
    if (km < 1) {
      final meters = (km * 1000).round();
      return '$meters m';
    }
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: FoodtrackColors.cremeVintage,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: FoodtrackColors.noirBrule, width: 3),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: FoodtrackColors.noirBrule.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Header section ----
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon with colored background
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: foodtruck.isCurrentlyOpen
                                ? _accentColor
                                : FoodtrackColors.noirBrule.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: FoodtrackColors.noirBrule,
                              width: 2.5,
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
                            foodtruck.logoIcon,
                            size: 36,
                            color: foodtruck.isCurrentlyOpen
                                ? FoodtrackColors.cremeVintage
                                : FoodtrackColors.noirBrule.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name and cuisine
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodtruck.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: FoodtrackColors.noirBrule,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (foodtruck.cuisineType != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FoodtrackColors.jauneMoutarde,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: FoodtrackColors.noirBrule,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    foodtruck.cuisineType!.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: FoodtrackColors.noirBrule,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              // Rating + seniority
                              if (foodtruck.reviewCount > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    StarRating(
                                      rating: foodtruck.averageRating,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${Formatters.rating(foodtruck.averageRating)} '
                                      '(${foodtruck.reviewCount})',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: FoodtrackColors.noirBrule,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (foodtruck.proSince != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Membre FoodTrack depuis '
                                  '${Formatters.monthYear(foodtruck.proSince!)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: FoodtrackColors.noirBrule
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Open/Closed badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: foodtruck.isCurrentlyOpen
                                ? FoodtrackColors.vertPickle
                                : FoodtrackColors.noirBrule.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: FoodtrackColors.noirBrule,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: foodtruck.isCurrentlyOpen
                                      ? FoodtrackColors.cremeVintage
                                      : FoodtrackColors.noirBrule.withOpacity(
                                          0.4,
                                        ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                foodtruck.isCurrentlyOpen ? 'OUVERT' : 'FERME',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: foodtruck.isCurrentlyOpen
                                      ? FoodtrackColors.cremeVintage
                                      : FoodtrackColors.noirBrule.withOpacity(
                                          0.5,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ---- Status & Hours row ----
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                      child: Row(
                        children: [
                          // Location
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: FoodtrackColors.rougeKetchup,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    foodtruck.status,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: FoodtrackColors.noirBrule,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Distance from user (if location is active)
                          Consumer<FoodtruckService>(
                            builder: (context, service, child) {
                              final km = service.distanceToFoodtruck(foodtruck);
                              if (km == null) return const SizedBox.shrink();
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (service.hasUserLocation) ...[
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: FoodtrackColors.noirBrule
                                          .withOpacity(0.2),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.near_me,
                                      size: 16,
                                      color: FoodtrackColors.rougeKetchup,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDistance(km),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: FoodtrackColors.noirBrule,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          // Today's hours
                          if (foodtruck.getTodayHours() != null) ...[
                            Container(
                              width: 1,
                              height: 20,
                              color: FoodtrackColors.noirBrule.withOpacity(0.2),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: foodtruck.isCurrentlyOpen
                                  ? FoodtrackColors.vertPickle
                                  : FoodtrackColors.noirBrule.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              foodtruck.getTodayHours()!,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: foodtruck.isCurrentlyOpen
                                    ? FoodtrackColors.vertPickle
                                    : FoodtrackColors.noirBrule.withOpacity(
                                        0.6,
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ---- Description (if any) ----
                    if (foodtruck.description != null &&
                        foodtruck.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: FoodtrackColors.noirBrule.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_quote,
                              size: 18,
                              color: FoodtrackColors.rougeKetchup.withOpacity(
                                0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                foodtruck.description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: FoodtrackColors.noirBrule.withOpacity(
                                    0.75,
                                  ),
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ---- Action buttons ----
                    Row(
                      children: [
                        // Itineraire button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // TODO: Open navigation app with coordinates
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FoodtrackColors.noirBrule,
                              side: const BorderSide(
                                color: FoodtrackColors.noirBrule,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                              Icons.directions,
                              size: 20,
                              color: FoodtrackColors.rougeKetchup,
                            ),
                            label: const Text(
                              'Itineraire',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Voir la fiche button
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed(
                                AppRouter.foodtruckDetail,
                                arguments: foodtruck,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: FoodtrackColors.cremeVintage,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(
                                  color: FoodtrackColors.noirBrule,
                                  width: 2,
                                ),
                              ),
                              elevation: 0,
                            ),
                            icon: Icon(foodtruck.logoIcon, size: 18),
                            label: const Text(
                              'Voir la fiche',
                              style: TextStyle(
                                fontSize: 14,
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
            ],
          ),
        ),
      ),
    );
  }
}
