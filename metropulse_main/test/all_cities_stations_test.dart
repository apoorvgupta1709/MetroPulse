import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metropulse_main/providers/transit_provider.dart';
import 'package:metropulse_main/services/transit_data_service.dart';
import 'package:metropulse_main/services/transit_graph_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('City-by-City Station & Line Validation Tests', () {
    final cities = TransitDataService.supportedCities;

    test('All 13 cities exist and have non-empty metadata', () {
      expect(cities.length, greaterThanOrEqualTo(13));
      for (final city in cities) {
        expect(city.id, isNotEmpty, reason: 'City ID must not be empty');
        expect(city.name, isNotEmpty, reason: 'City Name must not be empty for ${city.id}');
        expect(city.centerLatitude, inInclusiveRange(-90.0, 90.0));
        expect(city.centerLongitude, inInclusiveRange(-180.0, 180.0));
        expect(city.currencySymbol, isNotEmpty);
      }
    });

    for (final city in cities) {
      test('City "${city.name}" (${city.id}) has valid lines, stations and routing', () {
        final lines = TransitDataService.getLinesForCity(city.id);
        final stations = TransitDataService.getStationsForCity(city.id);

        // 1. Verify Lines
        expect(lines, isNotEmpty, reason: 'Lines must not be empty for ${city.name}');
        final lineIds = lines.map((l) => l.id).toSet();

        for (final line in lines) {
          expect(line.name, isNotEmpty);
          expect(line.firstTrain, isNotEmpty);
          expect(line.lastTrain, isNotEmpty);
          expect(line.frequencyMinutes, greaterThan(0));
          expect(line.colorHex, startsWith('#'));
          expect(line.startStationName, isNotEmpty);
          expect(line.endStationName, isNotEmpty);
          expect(line.stationIds, isNotEmpty);
        }

        // 2. Verify Stations
        expect(stations, isNotEmpty, reason: 'Stations must not be empty for ${city.name}');
        final stationIds = stations.map((s) => s.id).toSet();

        for (final station in stations) {
          expect(station.name, isNotEmpty);
          expect(station.latitude, inInclusiveRange(-90.0, 90.0));
          expect(station.longitude, inInclusiveRange(-180.0, 180.0));
          expect(station.lineIds, isNotEmpty, reason: 'Station ${station.name} must belong to at least 1 line');

          // Verify station line references exist
          for (final lId in station.lineIds) {
            expect(lineIds.contains(lId), isTrue,
                reason: 'Line $lId referenced by station ${station.name} must exist in city ${city.name}');
          }
        }

        // 3. Verify Offline Graph Routing Engine
        if (stations.length >= 2) {
          final graph = TransitGraphService(stations: stations, lines: lines);
          final origin = stations.first;
          final destination = stations.last;

          final route = graph.calculateRoute(
            originStationId: origin.id,
            destinationStationId: destination.id,
          );
          if (route != null) {
            expect(route.totalStationsCount, greaterThanOrEqualTo(1));
            expect(route.travelTimeMinutes, greaterThan(0));
          }
        }
      });
    }

    test('TransitProvider switches across all cities smoothly', () {
      final transit = TransitProvider();

      for (final city in cities) {
        transit.switchCity(city, savePreference: false);
        expect(transit.activeCity.id, equals(city.id));
        expect(transit.lines, isNotEmpty);
        expect(transit.stations, isNotEmpty);
      }

      // Final check: reset back to default Delhi NCR
      final delhi = cities.firstWhere((c) => c.id == 'delhi_ncr');
      transit.switchCity(delhi, savePreference: false);
      expect(transit.activeCity.id, equals('delhi_ncr'));
    });
  });
}
