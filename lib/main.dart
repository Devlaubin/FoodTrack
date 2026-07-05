import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/app/app_state.dart';
import 'package:foodtruck_app/theme/app_theme.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodtrack',
      debugShowCheckedModeBanner: false,
      theme: buildFoodtrackTheme(),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showHome = false;

  @override
  Widget build(BuildContext context) {
    if (_showHome) {
      return const FoodRadarHome();
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: FoodtrackColors.cremeVintage,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: FoodtrackColors.noirBrule, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: FoodtrackColors.noirBrule,
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lunch_dining,
                  size: 72,
                  color: FoodtrackColors.rougeKetchup,
                ),
                const SizedBox(height: 16),
                Text(
                  'Foodtrack',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 36),
                ),
                const SizedBox(height: 12),
                const Text(
                  'On fait chauffer les moteurs...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: FoodtrackColors.noirBrule,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showHome = true;
                    });
                    Navigator.of(context).pushReplacementNamed(AppRouter.home);
                  },
                  child: const Text('Entrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodRadarHome extends StatelessWidget {
  const FoodRadarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final foodtrucks = [
      _FoodtruckSpot(
        name: 'Burger Lab',
        status: 'Ouvert',
        accent: FoodtrackColors.rougeKetchup,
        position: const LatLng(48.8566, 2.3522),
      ),
      _FoodtruckSpot(
        name: 'Tacos de la Rue',
        status: 'À 5 min',
        accent: FoodtrackColors.vertPickle,
        position: const LatLng(48.8575, 2.3548),
      ),
      _FoodtruckSpot(
        name: 'Pizz’Art',
        status: 'Pop-up',
        accent: FoodtrackColors.jauneMoutarde,
        position: const LatLng(48.8558, 2.3505),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Radar à food')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: FoodtrackColors.jauneMoutarde,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: FoodtrackColors.noirBrule, width: 3),
              ),
              child: const Text(
                'Le grill est en route',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: FoodtrackColors.noirBrule,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: FoodtrackColors.cremeVintage,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: FoodtrackColors.noirBrule,
                    width: 3,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.map_outlined,
                          color: FoodtrackColors.rougeKetchup,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Carte des foodtrucks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: FoodtrackColors.noirBrule,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: const MapOptions(
                                initialCenter: LatLng(48.8566, 2.3522),
                                initialZoom: 13.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName:
                                      'com.example.foodtruck_app',
                                  maxZoom: 19,
                                  errorTileCallback: (_, __, ___) {},
                                ),
                                MarkerLayer(
                                  markers: foodtrucks
                                      .map(
                                        (spot) => Marker(
                                          point: spot.position,
                                          width: 72,
                                          height: 72,
                                          child: GestureDetector(
                                            onTap: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${spot.name} — ${spot.status}',
                                                  ),
                                                  backgroundColor:
                                                      FoodtrackColors.noirBrule,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: spot.accent,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                border: Border.all(
                                                  color:
                                                      FoodtrackColors.noirBrule,
                                                  width: 2,
                                                ),
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: FoodtrackColors
                                                        .noirBrule,
                                                    offset: Offset(3, 3),
                                                    blurRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.fastfood,
                                                color:
                                                    FoodtrackColors.noirBrule,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: FoodtrackColors.cremeVintage,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: FoodtrackColors.noirBrule,
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  'Touches de la ville',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: FoodtrackColors.noirBrule,
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
          ],
        ),
      ),
    );
  }
}

class _FoodtruckSpot {
  const _FoodtruckSpot({
    required this.name,
    required this.status,
    required this.accent,
    required this.position,
  });

  final String name;
  final String status;
  final Color accent;
  final LatLng position;
}
