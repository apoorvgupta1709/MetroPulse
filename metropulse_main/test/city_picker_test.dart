import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metropulse_main/providers/transit_provider.dart';
import 'package:metropulse_main/widgets/searchable_city_picker_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('TransitProvider defaults to Delhi NCR on startup', () {
    final transit = TransitProvider();
    expect(transit.activeCity.id, equals('delhi_ncr'));
    expect(transit.activeCity.name, contains('Delhi'));
  });

  testWidgets('SearchableCityPickerSheet renders and filters cities', (WidgetTester tester) async {
    final transit = TransitProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: transit,
        child: MaterialApp(
          home: Scaffold(
            body: SearchableCityPickerSheet(transit: transit),
          ),
        ),
      ),
    );

    // Verify header title and search bar
    expect(find.text('Select Metro Network'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Verify default city badge or tile is present
    expect(find.textContaining('Delhi NCR'), findsWidgets);

    // Filter by search query "Mumbai"
    await tester.enterText(find.byType(TextField), 'Mumbai');
    await tester.pumpAndSettle();

    // Verify Mumbai appears and Delhi is filtered out
    expect(find.textContaining('Mumbai'), findsWidgets);
    expect(find.textContaining('Delhi NCR Metro'), findsNothing);
  });
}
