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
  AuthService? _authService;
  bool _navigated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the reference once, so we never look it up from a deactivated
    // context (e.g. during dispose).
    _authService ??= context.read<AuthService>();
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final authService = _authService;
    if (authService == null) return;

    // Listen to auth state changes to react to sign-out while on splash
    authService.addListener(_onAuthChanged);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _goToInitialRoute(authService.isAuthenticated);
  }

  void _goToInitialRoute(bool isAuthenticated) {
    if (!mounted) return;
    if (_navigated) return;
    _navigated = true;

    if (isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final authService = _authService;
    if (authService == null) return;
    _goToInitialRoute(authService.isAuthenticated);
  }

  @override
  void dispose() {
    // Use the cached reference, never context.read() during dispose.
    final authService = _authService;
    if (authService != null) {
      authService.removeListener(_onAuthChanged);
    }
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
