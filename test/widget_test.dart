import 'package:flutter_test/flutter_test.dart';
import 'package:foodtruck_app/main.dart';

void main() {
  testWidgets('splash screen displays login and register buttons', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Foodtrack'), findsOneWidget);
    expect(find.text('On fait chauffer les moteurs...'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Creer un compte'), findsOneWidget);
  });

  testWidgets('navigates to login screen when login button is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
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
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 2));

    await tester.tap(find.text('Creer un compte'));
    await tester.pumpAndSettle();

    expect(find.text('Inscription'), findsOneWidget);
    expect(find.text('Rejoins la famille !'), findsOneWidget);
    expect(find.text('Tu es...'), findsOneWidget);
    expect(find.text('Creer mon compte'), findsOneWidget);
  });
}
