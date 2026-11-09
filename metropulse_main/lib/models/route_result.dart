import 'metro_line.dart';
import 'station.dart';

enum RouteMode { fastest, fewestChanges }

class RouteStep {
  final Station station;
  final MetroLine line;
  final int cumulativeMinutes;
  final bool isInterchangePoint;
  final MetroLine? nextLine;
  final String? platformGuide;
  final String? directionHeading;

  const RouteStep({
    required this.station,
    required this.line,
    required this.cumulativeMinutes,
    this.isInterchangePoint = false,
    this.nextLine,
    this.platformGuide,
    this.directionHeading,
  });
}

class RouteResult {
  final Station origin;
  final Station destination;
  final RouteMode mode;
  final List<RouteStep> steps;
  final int travelTimeMinutes;
  final int numberOfInterchanges;
  final int totalStationsCount;
  final double estimatedDistanceKm;
  final int fareAmount;
  final String currencySymbol;

  const RouteResult({
    required this.origin,
    required this.destination,
    required this.mode,
    required this.steps,
    required this.travelTimeMinutes,
    required this.numberOfInterchanges,
    required this.totalStationsCount,
    required this.estimatedDistanceKm,
    required this.fareAmount,
    required this.currencySymbol,
  });
}
