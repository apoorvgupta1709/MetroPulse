import 'package:flutter_test/flutter_test.dart';
import 'package:metropulse_main/services/transit_data_service.dart';
import 'package:metropulse_main/services/transit_graph_service.dart';
import 'package:metropulse_main/models/route_result.dart';

void main() {
  test('Test ALL pairs in Delhi NCR Metro for fastest and fewest changes', () {
    final stations = TransitDataService.getStationsForCity('delhi_ncr');
    final lines = TransitDataService.getLinesForCity('delhi_ncr');

    print('Total stations: ${stations.length}');
    print('Total lines: ${lines.length}');

    final graph = TransitGraphService(stations: stations, lines: lines);

    int nullFastest = 0;
    int nullFewest = 0;
    List<String> failedPairs = [];

    // Test a sample or all pairs
    for (int i = 0; i < stations.length; i++) {
      final s1 = stations[i];
      for (int j = 0; j < stations.length; j++) {
        if (i == j) continue;
        final s2 = stations[j];

        final fastest = graph.calculateRoute(
          originStationId: s1.id,
          destinationStationId: s2.id,
          mode: RouteMode.fastest,
        );
        if (fastest == null) {
          nullFastest++;
          failedPairs.add('Fastest null: ${s1.name} (${s1.id}) -> ${s2.name} (${s2.id})');
        }

        final fewest = graph.calculateRoute(
          originStationId: s1.id,
          destinationStationId: s2.id,
          mode: RouteMode.fewestChanges,
        );
        if (fewest == null) {
          nullFewest++;
          failedPairs.add('Fewest null: ${s1.name} (${s1.id}) -> ${s2.name} (${s2.id})');
        }
      }
    }

    print('Tested ${stations.length * (stations.length - 1)} pairs!');
    print('Null fastest count: $nullFastest');
    print('Null fewest count: $nullFewest');
    if (failedPairs.isNotEmpty) {
      print('First 20 failed pairs:');
      for (var f in failedPairs.take(20)) {
        print('  $f');
      }
    }

    expect(nullFastest, 0, reason: 'Every station pair in Delhi NCR must have a fastest route!');
    expect(nullFewest, 0, reason: 'Every station pair in Delhi NCR must have a fewest changes route!');
  });
}
