import 'package:flutter/material.dart';
import 'package:foodtruck_app/app/app_router.dart';
import 'package:foodtruck_app/config/supabase_config.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:foodtruck_app/services/foodtruck_service.dart';
import 'package:foodtruck_app/services/pro_service.dart';
import 'package:foodtruck_app/theme/app_theme.dart';
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
        ChangeNotifierProvider(
          create: (_) => ProService(Supabase.instance.client),
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
