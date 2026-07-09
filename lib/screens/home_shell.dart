import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/user_profile.dart';
import 'package:foodtruck_app/main.dart';
import 'package:foodtruck_app/screens/profile_screen.dart';
import 'package:foodtruck_app/screens/pro/pro_dashboard_screen.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

/// Wraps the main app screens with a bottom navigation bar:
/// Carte (map) / Profil, plus a Pro tab for foodtruck-owner accounts.
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
      const ProfileScreen(),
      if (isPro) const ProDashboardScreen(),
    ];

    final safeIndex = _index < tabs.length ? _index : 0;

    final destinations = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map),
        label: 'Carte',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
      if (isPro)
        const BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront),
          label: 'Pro',
        ),
    ];

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: FoodtrackColors.noirBrule, width: 2),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (value) => setState(() => _index = value),
          selectedItemColor: FoodtrackColors.rougeKetchup,
          unselectedItemColor: FoodtrackColors.noirBrule.withOpacity(0.5),
          backgroundColor: FoodtrackColors.cremeVintage,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: destinations,
        ),
      ),
    );
  }
}
