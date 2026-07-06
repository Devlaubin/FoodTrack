import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/config/supabase_config.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/theme/app_theme.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:foodtruck_app/widgets/filter_panel.dart';
import 'package:foodtruck_app/widgets/foodtruck_bottom_sheet.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(Supabase.instance.client),
        ),
        ChangeNotifierProvider(
          create: (_) => FoodtruckService(Supabase.instance.client),
        ),
      ],
      child: const MyApp(),
    ),
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bob;

  bool _authChecked = false;
  bool _shouldNavigateHome = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bob = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.repeat(reverse: true);

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final authService = context.read<AuthService>();

    setState(() {
      _authChecked = true;
      _shouldNavigateHome = authService.isAuthenticated;
    });

    if (authService.isAuthenticated) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoodtrackColors.cremeVintage,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;

              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FoodtrackColors.cremeVintage,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: FoodtrackColors.noirBrule,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: FoodtrackColors.noirBrule,
                        offset: Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _shouldNavigateHome
                        ? _SplashTransitionView(animation: _bob)
                        : _SplashAuthView(
                            animation: _bob,
                            authChecked: _authChecked,
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SplashTransitionView extends StatelessWidget {
  const _SplashTransitionView({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final scale = Tween<double>(begin: 0.98, end: 1.04).animate(animation);

    return Center(
      key: const ValueKey('navigate-home'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RetroBurgerCan(animation: animation, iconSize: 78),
          const SizedBox(height: 18),
          ScaleTransition(
            scale: scale,
            child: const Text(
              'Le grill s\'ouvre...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FoodtrackColors.noirBrule,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashAuthView extends StatelessWidget {
  const _SplashAuthView({required this.animation, required this.authChecked});

  final Animation<double> animation;
  final bool authChecked;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const ValueKey('auth-view'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RetroBurgerCan(animation: animation, iconSize: 78),
          const SizedBox(height: 16),
          Text(
            'Foodtrack',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            authChecked ? 'Bienvenue !' : 'On fait chauffer les moteurs...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: FoodtrackColors.noirBrule,
            ),
          ),
          const SizedBox(height: 24),
          if (authChecked)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRouter.login);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FoodtrackColors.rougeKetchup,
                        foregroundColor: FoodtrackColors.cremeVintage,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRouter.register);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FoodtrackColors.vertPickle,
                        foregroundColor: FoodtrackColors.cremeVintage,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: const BorderSide(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Creer un compte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _RetroBurgerCan extends StatelessWidget {
  const _RetroBurgerCan({required this.animation, required this.iconSize});

  final Animation<double> animation;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final translateY = Tween<double>(begin: 0, end: -10).animate(animation);
    final rotate = Tween<double>(begin: -0.12, end: 0.12).animate(animation);

    return SizedBox(
      width: iconSize * 2.2,
      height: iconSize * 1.7,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final opacity = (0.25 + 0.25 * animation.value).clamp(0.0, 1.0);
                final radius = 46 + 8 * animation.value;
                return Opacity(
                  opacity: opacity,
                  child: Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: FoodtrackColors.rougeKetchup.withOpacity(0.15),
                      border: Border.all(
                        color: FoodtrackColors.noirBrule.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, translateY.value),
                child: Transform.rotate(
                  angle: rotate.value,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 0,
                        child: Transform.translate(
                          offset: const Offset(4, 4),
                          child: Icon(
                            Icons.fastfood,
                            size: iconSize,
                            color: FoodtrackColors.noirBrule.withOpacity(0.85),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.fastfood,
                        size: iconSize,
                        color: FoodtrackColors.rougeKetchup,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final t = (i / 4);
                final phase = (animation.value - t).abs();
                final opacity = (1 - phase).clamp(0.2, 1.0);
                final size = 6 + 3 * opacity;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: FoodtrackColors.noirBrule.withOpacity(opacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class FoodRadarHome extends StatefulWidget {
  const FoodRadarHome({super.key});

  @override
  State<FoodRadarHome> createState() => _FoodRadarHomeState();
}

class _FoodRadarHomeState extends State<FoodRadarHome> {
  bool _showFilters = false;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthService, FoodtruckService>(
      builder: (context, auth, foodtruckService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Radar a food'),
            actions: [
              if (auth.profile != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: auth.profile!.role.toString().split('.').last ==
                                  'pro'
                              ? FoodtrackColors.vertPickle
                              : FoodtrackColors.jauneMoutarde,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FoodtrackColors.noirBrule,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          auth.profile!.role.toString().split('.').last == 'pro'
                              ? 'PRO'
                              : 'Client',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: FoodtrackColors.noirBrule,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRouter.splash);
                  }
                },
                tooltip: 'Deconnexion',
              ),
            ],
          ),
          body: foodtruckService.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: FoodtrackColors.rougeKetchup,
                  ),
                )
              : foodtruckService.error != null
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
                    )
                  : Padding(
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
                              border: Border.all(
                                color: FoodtrackColors.noirBrule,
                                width: 3,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    auth.profile != null
                                        ? 'Salut, ${auth.profile!.displayName ?? auth.profile!.email.split('@').first} !'
                                        : 'Le grill est en route',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: FoodtrackColors.noirBrule,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FoodtrackColors.cremeVintage,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: FoodtrackColors.noirBrule,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    '${foodtruckService.foodtrucks.length} trucks',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: FoodtrackColors.noirBrule,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Filter toggle button
                          GestureDetector(
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
                                  if (foodtruckService.cuisineTypeFilter !=
                                          null ||
                                      foodtruckService.openNowFilter) ...[
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

                          if (_showFilters) ...[
                            const SizedBox(height: 12),
                            const FilterPanel(),
                          ],

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
                                    child: foodtruckService.foodtrucks.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.fastfood_outlined,
                                                  size: 64,
                                                  color: FoodtrackColors
                                                      .noirBrule
                                                      .withOpacity(0.3),
                                                ),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  'Aucun foodtruck trouve',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: FoodtrackColors
                                                        .noirBrule,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  'Essaie d\'elargir tes filtres',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: FoodtrackColors
                                                        .noirBrule,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                            child: Stack(
                                              children: [
                                                FlutterMap(
                                                  mapController:
                                                      _mapController,
                                                  options: MapOptions(
                                                    initialCenter:
                                                        foodtruckService
                                                                .foodtrucks
                                                                .isNotEmpty
                                                            ? foodtruckService
                                                                .foodtrucks
                                                                .first
                                                                .position
                                                            : const LatLng(
                                                                48.8566,
                                                                2.3522),
                                                    initialZoom: 13.0,
                                                  ),
                                                  children: [
                                                    TileLayer(
                                                      urlTemplate:
                                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                      userAgentPackageName:
                                                          'com.example.foodtruck_app',
                                                      maxZoom: 19,
                                                      errorTileCallback:
                                                          (tile, error,
                                                              stackTrace) {},
                                                    ),
                                                    MarkerLayer(
                                                      markers:
                                                          foodtruckService
                                                              .foodtrucks
                                                              .map(
                                                                (foodtruck) =>
                                                                    Marker(
                                                                  point:
                                                                      foodtruck
                                                                          .position,
                                                                  width: 72,
                                                                  height: 72,
                                                                  child:
                                                                      _StickerMarker(
                                                                    foodtruck:
                                                                        foodtruck,
                                                                    onTap: () {
                                                                      showFoodtruckBottomSheet(
                                                                        context,
                                                                        foodtruck,
                                                                      );
                                                                    },
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
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: FoodtrackColors
                                                          .cremeVintage,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: FoodtrackColors
                                                            .noirBrule,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${foodtruckService.foodtrucks.length} trucks',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: FoodtrackColors
                                                            .noirBrule,
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
      },
    );
  }
}

class _StickerMarker extends StatelessWidget {
  const _StickerMarker({
    required this.foodtruck,
    required this.onTap,
  });

  final FoodTruck foodtruck;
  final VoidCallback onTap;

  Color get _accentColor {
    if (foodtruck.isCurrentlyOpen) {
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
    return FoodtrackColors.noirBrule.withOpacity(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FoodtrackColors.noirBrule,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: FoodtrackColors.noirBrule,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          Icons.fastfood,
          color: foodtruck.isCurrentlyOpen
              ? FoodtrackColors.cremeVintage
              : FoodtrackColors.noirBrule.withOpacity(0.3),
        ),
      ),
    );
  }
}
