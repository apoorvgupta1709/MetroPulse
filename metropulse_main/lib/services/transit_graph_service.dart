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
          final isExpress = line.id.toLowerCase().contains('airport') || line.id.toLowerCase().contains('rrts');
          final hopTime = isExpress ? 3.5 : 2.1;

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

    final ss = stationMap['del_shaheed_sthal'];
    final gz = stationMap['del_rrts_ghaziabad'];
    final rrts = lineMap['delhi_meerut_rrts'] ?? lineMap.values.first;
    if (ss != null && gz != null) {
      _adjacencyList.putIfAbsent(ss.id, () => []).add(_GraphEdge(toStation: gz, line: rrts, weightMinutes: 4.0));
      _adjacencyList.putIfAbsent(gz.id, () => []).add(_GraphEdge(toStation: ss, line: rrts, weightMinutes: 4.0));
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

    final fastest = _runRouting(
      origin: origin,
      destination: destination,
      mode: RouteMode.fastest,
      currencySymbol: currencySymbol,
    );

    if (mode == RouteMode.fastest) {
      return fastest ??
          _runRouting(
            origin: origin,
            destination: destination,
            mode: RouteMode.fewestChanges,
            currencySymbol: currencySymbol,
          );
    }

    // Mode is RouteMode.fewestChanges:
    final fewest = _runRouting(
      origin: origin,
      destination: destination,
      mode: RouteMode.fewestChanges,
      currencySymbol: currencySymbol,
    );

    if (fewest == null) return fastest;
    if (fastest == null) return fewest;

    // Guardrail: If fewest changes takes > 35% longer travel time or > 14 extra mins than fastest,
    // it's an unreasonable detour (e.g. 80 mins vs 40 mins). Fall back to fastest route!
    final maxAllowedMinutes = max(
      (fastest.travelTimeMinutes * 1.35).round(),
      fastest.travelTimeMinutes + 14,
    );
    if (fewest.travelTimeMinutes > maxAllowedMinutes) {
      return fastest;
    }

    return fewest;
  }

  static double _haversineDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    if (lat1 == 0.0 || lon1 == 0.0 || lat2 == 0.0 || lon2 == 0.0) return 0.0;
    const r = 6371.0; // Earth radius in km
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) *
            cos(lat2 * pi / 180.0) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  bool _isSameLineFamily(String? line1, String? line2) {
    if (line1 == null || line2 == null) return false;
    if (line1 == line2) return true;
    final l1 = line1.toLowerCase();
    final l2 = line2.toLowerCase();
    if (l1.contains('blue') && l2.contains('blue')) return true;
    if (l1.contains('green') && l2.contains('green')) return true;
    if (l1.contains('rrts') && l2.contains('meerut')) return true;
    if (l1.contains('meerut') && l2.contains('rrts')) return true;
    return false;
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
      final fromStation = stationMap[current.stationId];

      for (final edge in neighbors) {
        final toStation = edge.toStation;

        // Spatial progression / Anti-detour penalty
        double backtrackPenalty = 0.0;
        if (fromStation != null) {
          final distFromToDest = _haversineDistanceKm(
            fromStation.latitude,
            fromStation.longitude,
            destination.latitude,
            destination.longitude,
          );
          final distToToDest = _haversineDistanceKm(
            toStation.latitude,
            toStation.longitude,
            destination.latitude,
            destination.longitude,
          );

          if (distFromToDest > 0.0 && distToToDest > 0.0) {
            final delta = distToToDest - distFromToDest;
            // When a transit hop moves substantially further away from destination
            if (delta > 0.8) {
              backtrackPenalty = (delta - 0.8) * 3.0;
            }
          }
        }

        // Line transfer penalty
        double transferPenalty = 0.0;
        bool isLineSwitch = false;
        if (current.lineId != null && current.lineId != edge.line.id) {
          final isSameFamily = _isSameLineFamily(current.lineId, edge.line.id);
          if (isSameFamily) {
            transferPenalty = 1.0;
          } else {
            isLineSwitch = true;
            transferPenalty = 4.5;
          }
        }

        final double hopCost;
        if (mode == RouteMode.fastest) {
          hopCost = edge.weightMinutes + transferPenalty + backtrackPenalty;
        } else {
          // Fewest Changes: value saving a line change at ~12 mins, with strong anti-detour weight
          final changeWeight = isLineSwitch ? 12.0 : 0.0;
          hopCost = edge.weightMinutes + changeWeight + (backtrackPenalty * 3.5);
        }

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
        final sameFamily = _isSameLineFamily(activeLine.id, lineForThisHop.id);
        if (!sameFamily) {
          isInterchange = true;
          interchanges++;
          cumulativeMinutes += 5; // 5 min transfer walking & train wait
        } else {
          cumulativeMinutes += 1; // 1 min cross-platform transfer
        }
      }

      if (i < pathEdges.length - 1 && pathEdges[i].line.id != pathEdges[i + 1].line.id) {
        final sameFamily = _isSameLineFamily(pathEdges[i].line.id, pathEdges[i + 1].line.id);
        if (!sameFamily) {
          isInterchange = true;
          nextLine = pathEdges[i + 1].line;
        }
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
    final fare = _calculateFareForEdges(pathEdges, totalHops, currencySymbol);

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

  int _calculateFareForEdges(List<_GraphEdge> edges, int totalHops, String currencySymbol) {
    if (currencySymbol != '₹' || edges.isEmpty) {
      return _calculateFare(totalHops, currencySymbol);
    }

    int dmrcHops = 0;
    int aquaHops = 0;
    int rapidHops = 0;
    int airportHops = 0;
    int rrtsHops = 0;
    int meerutHops = 0;

    for (final e in edges) {
      final lineId = e.line.id.toLowerCase();
      if (lineId.contains('aqua')) {
        aquaHops++;
      } else if (lineId.contains('rapid')) {
        rapidHops++;
      } else if (lineId.contains('airport') || lineId.contains('orange')) {
        airportHops++;
      } else if (lineId.contains('rrts')) {
        rrtsHops++;
      } else if (lineId.contains('meerut')) {
        meerutHops++;
      } else {
        dmrcHops++;
      }
    }

    // Pure single-operator routes
    if (aquaHops > 0 && dmrcHops == 0 && rapidHops == 0 && airportHops == 0 && rrtsHops == 0 && meerutHops == 0) {
      return _aquaFareForHops(aquaHops);
    }
    if (rapidHops > 0 && dmrcHops == 0 && aquaHops == 0 && airportHops == 0 && rrtsHops == 0 && meerutHops == 0) {
      return 20; // Gurugram Rapid Metro standalone flat rate
    }
    if (airportHops > 0 && dmrcHops == 0 && aquaHops == 0 && rapidHops == 0 && rrtsHops == 0 && meerutHops == 0) {
      return _airportFareForHops(airportHops);
    }
    if (rrtsHops > 0 && dmrcHops == 0 && aquaHops == 0 && rapidHops == 0 && airportHops == 0 && meerutHops == 0) {
      return _rrtsFareForHops(rrtsHops);
    }
    if (meerutHops > 0 && dmrcHops == 0 && aquaHops == 0 && rapidHops == 0 && airportHops == 0 && rrtsHops == 0) {
      return _meerutFareForHops(meerutHops);
    }
    if (dmrcHops > 0 && aquaHops == 0 && rapidHops == 0 && airportHops == 0 && rrtsHops == 0 && meerutHops == 0) {
      return _dmrcFareForHops(dmrcHops);
    }

    // Integrated / Multi-network travel
    int totalFare = 0;
    if (dmrcHops > 0) totalFare += _dmrcFareForHops(dmrcHops);
    if (aquaHops > 0) totalFare += _aquaFareForHops(aquaHops);
    if (rapidHops > 0) totalFare += 20;
    if (airportHops > 0) totalFare += _airportFareForHops(airportHops);
    if (rrtsHops > 0) totalFare += _rrtsFareForHops(rrtsHops);
    if (meerutHops > 0) totalFare += _meerutFareForHops(meerutHops);

    return totalFare > 0 ? totalFare : _calculateFare(totalHops, currencySymbol);
  }

  int _dmrcFareForHops(int hops) {
    if (hops <= 2) return 10;
    if (hops <= 5) return 20;
    if (hops <= 9) return 30;
    if (hops <= 15) return 40;
    if (hops <= 22) return 50;
    return 60;
  }

  int _aquaFareForHops(int hops) {
    if (hops <= 1) return 10;
    if (hops <= 2) return 15;
    if (hops <= 6) return 20;
    if (hops <= 9) return 30;
    if (hops <= 16) return 40;
    return 50;
  }

  int _airportFareForHops(int hops) {
    if (hops <= 2) return 20;
    if (hops <= 4) return 30;
    if (hops <= 6) return 40;
    if (hops <= 8) return 50;
    return 60;
  }

  int _rrtsFareForHops(int hops) {
    if (hops <= 2) return 20;
    if (hops <= 4) return 40;
    if (hops <= 7) return 60;
    if (hops <= 10) return 90;
    return 120;
  }

  int _meerutFareForHops(int hops) {
    if (hops <= 2) return 10;
    if (hops <= 5) return 20;
    if (hops <= 9) return 30;
    return 40;
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
