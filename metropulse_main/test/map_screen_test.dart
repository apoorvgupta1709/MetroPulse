import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metropulse_main/models/station.dart';
import 'package:metropulse_main/models/metro_line.dart';
import 'package:metropulse_main/widgets/crisp_vector_map.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CrispVectorMap widget mounts cleanly and renders action buttons', (WidgetTester tester) async {
    final List<Station> mockStations = [
      const Station(
        id: 'del_rajiv_chowk',
        name: 'Rajiv Chowk',
        hindiName: 'राजीव चौक',
        cityId: 'delhi',
        lineIds: ['yellow', 'blue'],
        latitude: 28.6328,
        longitude: 77.2197,
        isInterchange: true,
        gates: [],
        facilities: StationFacilities(
          hasParking: true,
          hasEscalator: true,
          hasElevator: true,
          hasAtm: true,
          hasRestroom: true,
        ),
        platformDirections: {},
      ),
      const Station(
        id: 'del_kashmere_gate',
        name: 'Kashmere Gate',
        hindiName: 'कश्मीरी गेट',
        cityId: 'delhi',
        lineIds: ['red', 'yellow', 'violet'],
        latitude: 28.6675,
        longitude: 77.2285,
        isInterchange: true,
        gates: [],
        facilities: StationFacilities(
          hasParking: true,
          hasEscalator: true,
          hasElevator: true,
          hasAtm: true,
          hasRestroom: true,
        ),
        platformDirections: {},
      ),
    ];

    final List<MetroLine> mockLines = [
      const MetroLine(
        id: 'yellow',
        name: 'Yellow Line',
        cityId: 'delhi',
        code: 'YL',
        colorHex: '#FFCC00',
        firstTrain: '05:30 AM',
        lastTrain: '11:30 PM',
        frequencyMinutes: 3,
        stationIds: ['del_samaypur_badli', 'del_kashmere_gate', 'del_rajiv_chowk'],
        startStationName: 'Samaypur Badli',
        endStationName: 'Millennium City Centre',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CrispVectorMap(
            stations: mockStations,
            lines: mockLines,
            is4KActive: true,
            isFullscreen: false,
          ),
        ),
      ),
    );

    // Verify 4K button exists
    expect(find.text('4K'), findsOneWidget);

    // Verify Action buttons (Zoom in +, Zoom out -, Recenter, Fullscreen)
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(find.byIcon(Icons.open_in_full), findsOneWidget);
  });
}
