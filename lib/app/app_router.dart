import 'package:flutter/material.dart';
import 'package:foodtruck_app/domain/foodtruck.dart';
import 'package:foodtruck_app/screens/auth/login_screen.dart';
import 'package:foodtruck_app/screens/auth/register_screen.dart';
import 'package:foodtruck_app/screens/foodtruck_detail_screen.dart';
import 'package:foodtruck_app/screens/foodtruck_list_screen.dart';
import 'package:foodtruck_app/screens/home_shell.dart';
import 'package:foodtruck_app/screens/food_radar_home.dart';
import 'package:foodtruck_app/screens/splash_screen.dart';
import 'package:foodtruck_app/screens/support/feedback_screen.dart';
import 'package:foodtruck_app/screens/support/my_reports_screen.dart';
import 'package:foodtruck_app/screens/support/report_user_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String foodtruckDetail = '/foodtruck';
  static const String foodtruckList = '/list';
  static const String feedback = '/feedback';
  static const String reportUser = '/report-user';
  static const String myReports = '/my-reports';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeShell());
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
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case reportUser:
        return MaterialPageRoute(builder: (_) => const ReportUserScreen());
      case myReports:
        return MaterialPageRoute(builder: (_) => const MyReportsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
