import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/theme/colors.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final authService = context.read<AuthService>();

    // Listen to auth state changes to react to sign-out while on splash
    authService.addListener(_onAuthChanged);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (authService.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final authService = context.read<AuthService>();
    if (authService.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  void dispose() {
    // Remove listener to avoid calling setState after dispose
    context.read<AuthService>().removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.png',
              width: 240,
              height: 240,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                color: FoodtrackColors.rougeKetchup,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
