import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:foodtruck_app/main.dart';

void main() {
  testWidgets('navigates from splash to the food radar home', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Foodtrack'), findsOneWidget);
    expect(find.text('On fait chauffer les moteurs...'), findsOneWidget);

    await tester.tap(find.text('Entrer'));
    await tester.pumpAndSettle();

    expect(find.text('Radar à food'), findsOneWidget);
    expect(find.text('Le grill est en route'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
