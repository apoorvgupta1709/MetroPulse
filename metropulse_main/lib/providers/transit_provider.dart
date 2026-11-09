import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/metro_line.dart';
import '../models/route_result.dart';
import '../models/service_alert.dart';
import '../models/station.dart';
import '../services/transit_data_service.dart';
import '../services/transit_graph_service.dart';

class TransitProvider extends ChangeNotifier {
  List<City> _cities = [];
  late City _activeCity;
  List<MetroLine> _lines = [];
  List<Station> _stations = [];
  List<ServiceAlert> _alerts = [];
  late TransitGraphService _graphService;

  Station? _originStation;
  Station? _destinationStation;
  RouteResult? _fastestRoute;
  RouteResult? _fewestChangesRoute;
  bool _isCalculating = false;

  // Getters
  List<City> get cities => _cities;
  City get activeCity => _activeCity;
  List<MetroLine> get lines => _lines;
  List<Station> get stations => _stations;
  List<ServiceAlert> get alerts => _alerts;
  Station? get originStation => _originStation;
  Station? get destinationStation => _destinationStation;
  RouteResult? get fastestRoute => _fastestRoute;
  RouteResult? get fewestChangesRoute => _fewestChangesRoute;
  bool get isCalculating => _isCalculating;

  TransitProvider() {
    _cities = TransitDataService.supportedCities;
    _activeCity = _cities.first; // Default: Delhi NCR
    _loadCityData(_activeCity.id);
  }

  void switchCity(City city) {
    if (_activeCity.id == city.id) return;
    _activeCity = city;
    _originStation = null;
    _destinationStation = null;
    _fastestRoute = null;
    _fewestChangesRoute = null;
    _loadCityData(city.id);
    notifyListeners();
  }

  void _loadCityData(String cityId) {
    _lines = TransitDataService.getLinesForCity(cityId);
    _stations = TransitDataService.getStationsForCity(cityId);
    _alerts = TransitDataService.getServiceAlertsForCity(cityId);
    _graphService = TransitGraphService(stations: _stations, lines: _lines);

    // Preselect defaults if available
    if (_stations.length >= 2) {
      _originStation = _stations[0];
      _destinationStation = _stations[1];
      computeRoutes();
    }
  }

  void setOrigin(Station? station) {
    _originStation = station;
    computeRoutes();
    notifyListeners();
  }

  void setDestination(Station? station) {
    _destinationStation = station;
    computeRoutes();
    notifyListeners();
  }

  void swapStations() {
    final temp = _originStation;
    _originStation = _destinationStation;
    _destinationStation = temp;
    computeRoutes();
    notifyListeners();
  }

  void computeRoutes() {
    if (_originStation == null || _destinationStation == null) {
      _fastestRoute = null;
      _fewestChangesRoute = null;
      notifyListeners();
      return;
    }

    if (_originStation!.id == _destinationStation!.id) {
      _fastestRoute = null;
      _fewestChangesRoute = null;
      notifyListeners();
      return;
    }

    _isCalculating = true;
    notifyListeners();

    _fastestRoute = _graphService.calculateRoute(
      originStationId: _originStation!.id,
      destinationStationId: _destinationStation!.id,
      mode: RouteMode.fastest,
      currencySymbol: _activeCity.currencySymbol,
    );

    _fewestChangesRoute = _graphService.calculateRoute(
      originStationId: _originStation!.id,
      destinationStationId: _destinationStation!.id,
      mode: RouteMode.fewestChanges,
      currencySymbol: _activeCity.currencySymbol,
    );

    _isCalculating = false;
    notifyListeners();
  }

  List<Station> searchStations(String query) {
    if (query.trim().isEmpty) return _stations;
    final q = query.toLowerCase();
    return _stations.where((s) {
      return s.name.toLowerCase().contains(q) ||
          s.hindiName.toLowerCase().contains(q) ||
          s.gates.any((g) => g.landmark.toLowerCase().contains(q));
    }).toList();
  }
}
