import 'package:flutter_test/flutter_test.dart';
import 'package:metropulse_main/models/route_result.dart';
import 'package:metropulse_main/services/transit_data_service.dart';
import 'package:metropulse_main/services/transit_graph_service.dart';

void main() {
  group('Delhi NCR Inter-Line Routing Tests', () {
    late TransitGraphService graphService;

    setUp(() {
      final stations = TransitDataService.getStationsForCity('delhi_ncr');
      final lines = TransitDataService.getLinesForCity('delhi_ncr');
      graphService = TransitGraphService(stations: stations, lines: lines);
    });

    test('Noida Sec 143 to Kashmere Gate (Fastest and Fewest Changes)', () {
      final rFastest = graphService.calculateRoute(
        originStationId: 'del_noida_sec_143',
        destinationStationId: 'del_kashmere_gate',
        mode: RouteMode.fastest,
      );
      print('Fastest: ' + (rFastest != null ? '${rFastest.totalStationsCount} stations, ${rFastest.travelTimeMinutes} mins, ${rFastest.numberOfInterchanges} changes' : 'NULL'));
      expect(rFastest, isNotNull);

      final rFewest = graphService.calculateRoute(
        originStationId: 'del_noida_sec_143',
        destinationStationId: 'del_kashmere_gate',
        mode: RouteMode.fewestChanges,
      );
      print('Fewest: ' + (rFewest != null ? '${rFewest.totalStationsCount} stations, ${rFewest.travelTimeMinutes} mins, ${rFewest.numberOfInterchanges} changes' : 'NULL'));
      expect(rFewest, isNotNull);
    });

    test('Yellow Line to Blue Line (Samaypur Badli -> Dwarka Sec 21)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_samaypur_badli',
        destinationStationId: 'del_dwarka_sec_21',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
      expect(route!.totalStationsCount, greaterThanOrEqualTo(20));
      expect(route.numberOfInterchanges, greaterThanOrEqualTo(1));
    });

    test('Red Line to Yellow Line (Rithala -> Millennium City Centre)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_rithala',
        destinationStationId: 'del_millennium_city_centre',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
      expect(route!.totalStationsCount, greaterThan(25));
      expect(route.numberOfInterchanges, greaterThanOrEqualTo(1));
    });

    test('Blue Branch to Yellow Line (Vaishali -> Millennium City Centre)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_vaishali',
        destinationStationId: 'del_millennium_city_centre',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
      expect(route!.totalStationsCount, greaterThanOrEqualTo(20));
      expect(route.numberOfInterchanges, greaterThanOrEqualTo(1));
    });

    test('Magenta to Violet (Janakpuri West -> Raja Nahar Singh)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_janakpuri_west',
        destinationStationId: 'del_raja_nahar_singh',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
      expect(route!.totalStationsCount, greaterThan(25));
    });

    test('Pink to Green (Majlis Park -> Brigadier Hoshiar Singh)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_majlis_park',
        destinationStationId: 'del_brigadier_hoshiar_singh',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
      expect(route!.totalStationsCount, greaterThan(20));
    });

    test('Airport Express to Blue (New Delhi -> Dwarka Sec 21 via Airport Line)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_new_delhi',
        destinationStationId: 'del_dwarka_sec_21',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
    });

    test('Blue Line to Aqua Line Pedestrian Transfer (Rajiv Chowk -> Depot Station)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_rajiv_chowk',
        destinationStationId: 'del_depot_station',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
      expect(route!.totalStationsCount, greaterThan(30));
    });

    test('Yellow Line to Aqua Line Dynamic Fare (Samaypur Badli -> Noida Sec 144)', () {
      final route = graphService.calculateRoute(
        originStationId: 'del_samaypur_badli',
        destinationStationId: 'del_noida_sec_144',
        mode: RouteMode.fastest,
      );
      expect(route, isNotNull);
      expect(route!.fareAmount, greaterThanOrEqualTo(60));
      // Short trip on Yellow Line should have low fare
      final shortRoute = graphService.calculateRoute(
        originStationId: 'del_samaypur_badli',
        destinationStationId: 'del_rohini_sec_18_19',
        mode: RouteMode.fastest,
      );
      expect(shortRoute, isNotNull);
      expect(shortRoute!.fareAmount, equals(10));
    });
  });
}
