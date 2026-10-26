import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/user_profile.dart';
import 'package:foodtruck_app/screens/food_radar_home.dart';
import 'package:foodtruck_app/screens/foodtruck_list_screen.dart';
import 'package:foodtruck_app/screens/profile_screen.dart';
import 'package:foodtruck_app/screens/pro/pro_dashboard_screen.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

/// Wraps the main app screens with mobile bottom navigation.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isPro = context.watch<AuthService>().profile?.role == UserRole.pro;

    final tabs = <Widget>[
      const FoodRadarHome(),
      const FoodtruckListScreen(),
      const ProfileScreen(),
      if (isPro) const ProDashboardScreen(),
    ];

    final safeIndex = _index < tabs.length ? _index : 0;

    final destinations = <GButton>[
      const GButton(icon: Icons.map_outlined, text: 'Carte'),
      const GButton(icon: Icons.restaurant_menu_outlined, text: 'Liste'),
      const GButton(icon: Icons.person_outline, text: 'Profil'),
      if (isPro) const GButton(icon: Icons.storefront_outlined, text: 'Pro'),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: safeIndex, children: tabs),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, FoodtrackColors.cremeVintage],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: FoodtrackColors.noirBrule.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: FoodtrackColors.jauneMoutarde.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: GNav(
              selectedIndex: safeIndex,
              onTabChange: (value) => setState(() => _index = value),
              haptic: true,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              gap: 5,
              color: FoodtrackColors.noirBrule.withValues(alpha: 0.65),
              activeColor: Colors.white,
              iconSize: 21,
              textSize: 11,
              tabBorderRadius: 24,
              tabBackgroundColor: FoodtrackColors.rougeKetchup,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              tabs: destinations,
            ),
          ),
        ),
      ),
    );
  }
}
