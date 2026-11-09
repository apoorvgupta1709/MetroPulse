import 'package:flutter_test/flutter_test.dart';
import 'package:metropulse_main/main.dart';

void main() {
  testWidgets('MetroPulse app boots and builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MetroPulseApp());
    expect(find.text('MetroPulse'), findsOneWidget);
  });
}
