import 'package:flutter_test/flutter_test.dart';
import 'package:metropulse_admin/main.dart';

void main() {
  testWidgets('MetroPulse Admin app boots and builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MetroPulseAdminApp());
    expect(find.text('MetroPulse Command Center'), findsOneWidget);
  });
}
