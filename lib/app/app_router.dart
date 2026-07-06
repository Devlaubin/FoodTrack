import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/main.dart';
import 'package:foodtruck_app/screens/auth/login_screen.dart';
import 'package:foodtruck_app/screens/auth/register_screen.dart';
import 'package:foodtruck_app/screens/foodtruck_detail_screen.dart';
import 'package:foodtruck_app/screens/foodtruck_list_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String foodtruckDetail = '/foodtruck';
  static const String foodtruckList = '/list';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const FoodRadarHome());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case foodtruckList:
        return MaterialPageRoute(builder: (_) => const FoodtruckListScreen());
      case foodtruckDetail:
        final foodtruck = settings.arguments as FoodTruck?;
        if (foodtruck == null) {
          return MaterialPageRoute(builder: (_) => const FoodRadarHome());
        }
        return MaterialPageRoute(
          builder: (_) => FoodtruckDetailScreen(foodtruck: foodtruck),
        );
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
