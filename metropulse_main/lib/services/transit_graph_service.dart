import 'dart:math';
import '../models/metro_line.dart';
import '../models/route_result.dart';
import '../models/station.dart';

class _GraphEdge {
  final Station toStation;
  final MetroLine line;
  final double weightMinutes;

  _GraphEdge({
    required this.toStation,
    required this.line,
    required this.weightMinutes,
  });
}

class _RouteState {
  final String stationId;
  final double cost;
  final String? lineId;

  _RouteState(this.stationId, this.cost, this.lineId);

  String get key => '$stationId::${lineId ?? "START"}';
}

class TransitGraphService {
  final Map<String, Station> stationMap;
  final Map<String, MetroLine> lineMap;
  final Map<String, List<_GraphEdge>> _adjacencyList = {};

  TransitGraphService({
    required List<Station> stations,
    required List<MetroLine> lines,
  })  : stationMap = {for (var s in stations) s.id: s},
        lineMap = {for (var l in lines) l.id: l} {
    _buildGraph();
  }

  void _buildGraph() {
    for (var line in lineMap.values) {
      final ids = line.stationIds;
      for (int i = 0; i < ids.length - 1; i++) {
        final s1Id = ids[i];
        final s2Id = ids[i + 1];

        final s1 = stationMap[s1Id];
        final s2 = stationMap[s2Id];

        if (s1 != null && s2 != null) {
          // Average travel time between two adjacent metro stations: 2.2 minutes
          const hopTime = 2.2;

          _adjacencyList.putIfAbsent(s1.id, () => []).add(
                _GraphEdge(toStation: s2, line: line, weightMinutes: hopTime),
              );
          _adjacencyList.putIfAbsent(s2.id, () => []).add(
                _GraphEdge(toStation: s1, line: line, weightMinutes: hopTime),
              );
        }
      }
    }

    // Connect official pedestrian transfer walkways & junctions
    final s52 = stationMap['del_noida_sec_52'];
    final s51 = stationMap['del_noida_sec_51'];
    final aqua = lineMap['aqua_noida'] ?? lineMap.values.first;
    if (s52 != null && s51 != null) {
      _adjacencyList.putIfAbsent(s52.id, () => []).add(_GraphEdge(toStation: s51, line: aqua, weightMinutes: 4.0));
      _adjacencyList.putIfAbsent(s51.id, () => []).add(_GraphEdge(toStation: s52, line: aqua, weightMinutes: 4.0));
    }

    final dk = stationMap['del_dhaula_kuan'];
    final sc = stationMap['del_durgabai_deshmukh_south_campus'];
    final pink = lineMap['pink'] ?? lineMap.values.first;
    if (dk != null && sc != null) {
      _adjacencyList.putIfAbsent(dk.id, () => []).add(_GraphEdge(toStation: sc, line: pink, weightMinutes: 6.0));
      _adjacencyList.putIfAbsent(sc.id, () => []).add(_GraphEdge(toStation: dk, line: pink, weightMinutes: 6.0));
    }

    final ap = stationMap['del_ashok_park_main'];
    final il = stationMap['del_inderlok'];
    final kn = stationMap['del_kirti_nagar'];
    final green = lineMap['green'] ?? lineMap.values.first;
    if (ap != null) {
      if (il != null) {
        _adjacencyList.putIfAbsent(ap.id, () => []).add(_GraphEdge(toStation: il, line: green, weightMinutes: 3.5));
        _adjacencyList.putIfAbsent(il.id, () => []).add(_GraphEdge(toStation: ap, line: green, weightMinutes: 3.5));
      }
      if (kn != null) {
        _adjacencyList.putIfAbsent(ap.id, () => []).add(_GraphEdge(toStation: kn, line: green, weightMinutes: 3.5));
        _adjacencyList.putIfAbsent(kn.id, () => []).add(_GraphEdge(toStation: ap, line: green, weightMinutes: 3.5));
      }
    }
  }

  /// Calculates route according to specified mode (fastest vs fewest line changes)
  RouteResult? calculateRoute({
    required String originStationId,
    required String destinationStationId,
    RouteMode mode = RouteMode.fastest,
    String currencySymbol = '₹',
  }) {
    if (originStationId == destinationStationId) return null;
    final origin = stationMap[originStationId];
    final destination = stationMap[destinationStationId];
    if (origin == null || destination == null) return null;

    final primary = _runRouting(
      origin: origin,
      destination: destination,
      mode: mode,
      currencySymbol: currencySymbol,
    );

    if (primary != null) return primary;

    // Graceful fallback to alternative routing mode if one found no path
    final altMode = (mode == RouteMode.fastest) ? RouteMode.fewestChanges : RouteMode.fastest;
    return _runRouting(
      origin: origin,
      destination: destination,
      mode: altMode,
      currencySymbol: currencySymbol,
    );
  }

  /// State-based (stationId, lineId) routing search
  RouteResult? _runRouting({
    required Station origin,
    required Station destination,
    required RouteMode mode,
    required String currencySymbol,
  }) {
    final bestCosts = <String, double>{};
    final previousStates = <String, String>{};
    final previousEdges = <String, _GraphEdge>{};
    final previousStations = <String, Station>{};

    final priorityQueue = <_RouteState>[];

    final startState = _RouteState(origin.id, 0.0, null);
    bestCosts[startState.key] = 0.0;
    priorityQueue.add(startState);

    String? destinationEndKey;

    while (priorityQueue.isNotEmpty) {
      priorityQueue.sort((a, b) => a.cost.compareTo(b.cost));
      final current = priorityQueue.removeAt(0);

      // Stop once lowest cost path to destination is popped
      if (current.stationId == destination.id) {
        destinationEndKey = current.key;
        break;
      }

      final recordedCost = bestCosts[current.key];
      if (recordedCost != null && current.cost > recordedCost) {
        continue;
      }

      final neighbors = _adjacencyList[current.stationId] ?? [];
      for (final edge in neighbors) {
        // Line transfer penalty
        double penalty = 0.0;
        if (current.lineId != null && current.lineId != edge.line.id) {
          penalty = (mode == RouteMode.fewestChanges) ? 1000.0 : 5.0;
        }

        final hopCost = (mode == RouteMode.fewestChanges) ? (1.0 + penalty) : (edge.weightMinutes + penalty);
        final newCost = current.cost + hopCost;

        final nextState = _RouteState(edge.toStation.id, newCost, edge.line.id);

        if (newCost < (bestCosts[nextState.key] ?? double.infinity)) {
          bestCosts[nextState.key] = newCost;
          previousStates[nextState.key] = current.key;
          previousEdges[nextState.key] = edge;
          previousStations[nextState.key] = edge.toStation;
          priorityQueue.add(nextState);
        }
      }
    }

    if (destinationEndKey == null) {
      return null;
    }

    // Trace back path from destination to origin
    final pathStations = <Station>[];
    final pathEdges = <_GraphEdge>[];

    String? currKey = destinationEndKey;
    while (currKey != null && currKey != startState.key) {
      final stn = previousStations[currKey];
      final edge = previousEdges[currKey];
      if (stn != null) pathStations.insert(0, stn);
      if (edge != null) pathEdges.insert(0, edge);
      currKey = previousStates[currKey];
    }
    pathStations.insert(0, origin);

    return _reconstructPathFromEdges(
      origin: origin,
      destination: destination,
      pathStations: pathStations,
      pathEdges: pathEdges,
      mode: mode,
      currencySymbol: currencySymbol,
    );
  }

  RouteResult _reconstructPathFromEdges({
    required Station origin,
    required Station destination,
    required List<Station> pathStations,
    required List<_GraphEdge> pathEdges,
    required RouteMode mode,
    required String currencySymbol,
  }) {
    final steps = <RouteStep>[];
    int cumulativeMinutes = 0;
    int interchanges = 0;
    MetroLine? activeLine;

    for (int i = 0; i < pathStations.length; i++) {
      final stn = pathStations[i];
      MetroLine? lineForThisHop;
      if (i < pathEdges.length) {
        lineForThisHop = pathEdges[i].line;
      } else if (pathEdges.isNotEmpty) {
        lineForThisHop = pathEdges.last.line;
      } else {
        lineForThisHop = lineMap.values.first;
      }

      bool isInterchange = false;
      MetroLine? nextLine;
      if (activeLine != null && activeLine.id != lineForThisHop.id) {
        isInterchange = true;
        interchanges++;
        cumulativeMinutes += 5; // 5 min transfer walking & train wait
      }

      if (i < pathEdges.length - 1 && pathEdges[i].line.id != pathEdges[i + 1].line.id) {
        isInterchange = true;
        nextLine = pathEdges[i + 1].line;
      }

      if (i > 0) {
        cumulativeMinutes += 2; // 2 min station traversal
      }

      final directionText = _computeDirection(
        stn,
        lineForThisHop,
        i < pathStations.length - 1 ? pathStations[i + 1] : null,
      );

      steps.add(RouteStep(
        station: stn,
        line: lineForThisHop,
        cumulativeMinutes: cumulativeMinutes,
        isInterchangePoint: isInterchange,
        nextLine: nextLine,
        platformGuide: stn.platformDirections[lineForThisHop.id] ?? 'Check concourse signage',
        directionHeading: directionText,
      ));

      activeLine = lineForThisHop;
    }

    final totalHops = max(1, pathStations.length - 1);
    final distanceKm = (totalHops * 1.6).clamp(1.2, 85.0);
    final fare = _calculateFare(totalHops, currencySymbol);

    return RouteResult(
      origin: origin,
      destination: destination,
      mode: mode,
      steps: steps,
      travelTimeMinutes: cumulativeMinutes,
      numberOfInterchanges: interchanges,
      totalStationsCount: pathStations.length,
      estimatedDistanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      fareAmount: fare,
      currencySymbol: currencySymbol,
    );
  }

  String _computeDirection(Station current, MetroLine line, Station? next) {
    if (next == null) {
      return 'Destination Terminus';
    }
    final currentIndex = line.stationIds.indexOf(current.id);
    final nextIndex = line.stationIds.indexOf(next.id);

    if (currentIndex != -1 && nextIndex != -1) {
      if (nextIndex > currentIndex) {
        return 'Towards ${line.endStationName}';
      } else {
        return 'Towards ${line.startStationName}';
      }
    }
    return 'Towards ${line.endStationName}';
  }

  int _calculateFare(int hops, String currencySymbol) {
    if (currencySymbol == '₹') {
      if (hops <= 2) return 10;
      if (hops <= 5) return 20;
      if (hops <= 9) return 30;
      if (hops <= 15) return 40;
      if (hops <= 22) return 50;
      return 60;
    } else if (currencySymbol == 'AED') {
      if (hops <= 5) return 3;
      if (hops <= 12) return 5;
      return 8;
    } else if (currencySymbol == '£') {
      if (hops <= 4) return 3;
      if (hops <= 10) return 4;
      return 6;
    } else {
      if (hops <= 5) return 2;
      if (hops <= 12) return 3;
      return 4;
    }
  }
}
