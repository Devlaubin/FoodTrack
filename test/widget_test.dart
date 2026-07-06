import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodtruck_app/domain/user_profile.dart';
import 'package:foodtruck_app/main.dart';
import 'package:foodtruck_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestAuthService extends AuthService {
  TestAuthService()
    : super(SupabaseClient('https://example.supabase.co', 'anon-key'));

  bool _authenticated = false;

  Future<void> initForTest() async {
    _authenticated = false;
    notifyListeners();
  }

  @override
  bool get isLoading => false;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  Future<bool> signIn({required String email, required String password}) async {
    _authenticated = true;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required UserRole role,
    String? displayName,
  }) async {
    _authenticated = true;
    notifyListeners();
    return true;
  }
}

Widget buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthService>.value(value: TestAuthService()),
    ],
    child: const MyApp(),
  );
}

void main() {
  testWidgets('splash screen displays login and register buttons', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Foodtrack'), findsOneWidget);
    expect(find.text('On fait chauffer les moteurs...'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Creer un compte'), findsOneWidget);
  });

  testWidgets('navigates to login screen when login button is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Retrouve tes foodtrucks !'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
  });

  testWidgets('navigates to register screen when register button is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Creer un compte'));
    await tester.pumpAndSettle();

    expect(find.text('Inscription'), findsOneWidget);
    expect(find.text('Rejoins la famille !'), findsOneWidget);
    expect(find.text('Tu es...'), findsOneWidget);
    expect(find.text('Creer mon compte'), findsOneWidget);
  });

  testWidgets('navigates to home after a successful login', (tester) async {
    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Se connecter'));
    await tester.pumpAndSettle();

    expect(find.text('Radar a food'), findsOneWidget);
    expect(find.text('Le grill est en route'), findsOneWidget);
  });
}
