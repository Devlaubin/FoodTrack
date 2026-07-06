import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:foodtruck_app/widgets/filter_panel.dart';
import 'package:foodtruck_app/widgets/foodtruck_card.dart';
import 'package:provider/provider.dart';

class FoodtruckListScreen extends StatefulWidget {
  const FoodtruckListScreen({super.key});

  @override
  State<FoodtruckListScreen> createState() => _FoodtruckListScreenState();
}

class _FoodtruckListScreenState extends State<FoodtruckListScreen> {
  bool _showFilters = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodtruckService>(
      builder: (context, service, child) {
        return Scaffold(
          backgroundColor: FoodtrackColors.cremeVintage,
          appBar: AppBar(
            title: const Text('Tous les trucks'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FoodtrackColors.jauneMoutarde,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: FoodtrackColors.noirBrule,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '${service.foodtrucks.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: FoodtrackColors.noirBrule,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Filter toggle
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _showFilters
                          ? FoodtrackColors.rougeKetchup
                          : Colors.white,
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
                          Icons.filter_list,
                          size: 20,
                          color: _showFilters
                              ? FoodtrackColors.cremeVintage
                              : FoodtrackColors.noirBrule,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filtres',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _showFilters
                                ? FoodtrackColors.cremeVintage
                                : FoodtrackColors.noirBrule,
                          ),
                        ),
                        if (service.cuisineTypeFilter != null ||
                            service.openNowFilter) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: FoodtrackColors.vertPickle,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Actif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: FoodtrackColors.cremeVintage,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              if (_showFilters) ...[
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: FilterPanel(),
                ),
              ],

              const SizedBox(height: 12),

              // List
              Expanded(
                child: service.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: FoodtrackColors.rougeKetchup,
                        ),
                      )
                    : service.error != null
                        ? Center(
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
                                  service.error!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: FoodtrackColors.noirBrule,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: service.loadFoodtrucks,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        FoodtrackColors.rougeKetchup,
                                    foregroundColor:
                                        FoodtrackColors.cremeVintage,
                                  ),
                                  child: const Text('Reessayer'),
                                ),
                              ],
                            ),
                          )
                        : service.foodtrucks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fastfood_outlined,
                                      size: 64,
                                      color: FoodtrackColors.noirBrule
                                          .withOpacity(0.3),
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
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 100),
                                itemCount: service.foodtrucks.length,
                                itemBuilder: (context, index) {
                                  final foodtruck = service.foodtrucks[index];
                                  return FoodtruckCard(
                                    foodtruck: foodtruck,
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        AppRouter.foodtruckDetail,
                                        arguments: foodtruck,
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}
