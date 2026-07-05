import 'package:flutter/material.dart';
import 'package:foodtruck_app/main.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const FoodRadarHome());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
