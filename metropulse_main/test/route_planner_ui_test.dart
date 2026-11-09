import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metropulse_main/providers/auth_provider.dart';
import 'package:metropulse_main/providers/monetization_provider.dart';
import 'package:metropulse_main/providers/transit_provider.dart';
import 'package:metropulse_main/views/route_planner_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Route Planner computes and displays route from Noida Sec 143 to Kashmere Gate', (WidgetTester tester) async {
    final transit = TransitProvider();
    final monetization = MonetizationProvider();
    final auth = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TransitProvider>.value(value: transit),
          ChangeNotifierProvider<MonetizationProvider>.value(value: monetization),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: const MaterialApp(
          home: RoutePlannerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final noida143 = transit.stations.firstWhere((s) => s.name.contains('143'));
    final kg = transit.stations.firstWhere((s) => s.id == 'del_kashmere_gate');

    transit.setOrigin(noida143);
    transit.setDestination(kg);
    await tester.pumpAndSettle();

    // Check fastest route
    expect(transit.fastestRoute, isNotNull);
    expect(find.text('Select Origin and Destination to calculate route'), findsNothing);

    // Tap Fewest Changes
    await tester.tap(find.text('Fewest Changes'));
    await tester.pumpAndSettle();

    expect(transit.fewestChangesRoute, isNotNull);
    expect(find.text('Select Origin and Destination to calculate route'), findsNothing);
  });
}
