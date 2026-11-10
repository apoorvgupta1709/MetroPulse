import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city.dart';
import '../models/metro_line.dart';
import '../models/route_result.dart';
import '../models/service_alert.dart';
import '../models/station.dart';
import '../services/transit_data_service.dart';
import '../services/transit_graph_service.dart';
import '../services/transit_sync_service.dart';

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

  // Real-time Firestore sync subscriptions
  StreamSubscription<List<Station>>? _stationsSubscription;
  StreamSubscription<List<MetroLine>>? _linesSubscription;
  StreamSubscription<List<ServiceAlert>>? _alertsSubscription;
  StreamSubscription<List<City>>? _citiesSubscription;

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

  static const String _savedCityPrefKey = 'metropulse_active_city_id';

  TransitProvider() {
    _cities = TransitDataService.supportedCities;
    // Guaranteed baseline default: Delhi NCR
    final delhi = _cities.firstWhere(
      (c) => c.id == 'delhi_ncr' || c.name.toLowerCase().contains('delhi'),
      orElse: () => _cities.first,
    );
    _activeCity = delhi;
    _loadCityData(_activeCity.id);
    _initCloudSync();
    _loadSavedCity();
  }

  void switchCity(City city, {bool savePreference = true}) {
    if (_activeCity.id == city.id && _lines.isNotEmpty) return;
    _activeCity = city;
    _originStation = null;
    _destinationStation = null;
    _fastestRoute = null;
    _fewestChangesRoute = null;
    _loadCityData(city.id);
    _subscribeToActiveCityData(city.id);
    if (savePreference) {
      _persistSelectedCity(city.id);
    }
    notifyListeners();
  }

  Future<void> _persistSelectedCity(String cityId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedCityPrefKey, cityId);
    } catch (e) {
      debugPrint('Error saving city preference: $e');
    }
  }

  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCityId = prefs.getString(_savedCityPrefKey);
      if (savedCityId != null && savedCityId.isNotEmpty && savedCityId != _activeCity.id) {
        final match = _cities.firstWhere(
          (c) => c.id == savedCityId,
          orElse: () => _activeCity,
        );
        if (match.id != _activeCity.id) {
          switchCity(match, savePreference: false);
        }
      }
    } catch (e) {
      debugPrint('Error loading saved city: $e');
    }
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

  void _initCloudSync() {
    _subscribeToActiveCityData(_activeCity.id);

    // Global city updates
    _citiesSubscription?.cancel();
    _citiesSubscription = TransitSyncService.streamCities().listen((cloudCities) {
      if (cloudCities.isNotEmpty) {
        final Map<String, City> cityMap = {for (var c in _cities) c.id: c};
        for (var cc in cloudCities) {
          cityMap[cc.id] = cc;
        }
        _cities = cityMap.values.toList();
        notifyListeners();
      }
    }, onError: (e) => debugPrint('TransitProvider cloud cities sync notice: $e'));
  }

  void _subscribeToActiveCityData(String cityId) {
    // 1. Cancel existing city listeners
    _stationsSubscription?.cancel();
    _linesSubscription?.cancel();
    _alertsSubscription?.cancel();

    // 2. Real-time Stations synchronization
    _stationsSubscription = TransitSyncService.streamStations(cityId).listen((cloudStations) {
      if (cloudStations.isNotEmpty) {
        bool changed = false;
        final Map<String, Station> map = {for (var s in _stations) s.id: s};
        for (var cs in cloudStations) {
          final local = map[cs.id];
          if (local != null && (cs.name.isEmpty || cs.latitude == 0.0)) {
            continue;
          }
          map[cs.id] = cs;
          changed = true;
        }
        if (changed) {
          _stations = map.values.toList();
          _graphService = TransitGraphService(stations: _stations, lines: _lines);

          // Keep origin/destination intact or refresh if modified
          if (_originStation != null) {
            _originStation = _stations.firstWhere(
              (s) => s.id == _originStation!.id,
              orElse: () => _originStation!,
            );
          }
          if (_destinationStation != null) {
            _destinationStation = _stations.firstWhere(
              (s) => s.id == _destinationStation!.id,
              orElse: () => _destinationStation!,
            );
          }

          if (_originStation != null && _destinationStation != null) {
            computeRoutes();
          }
          notifyListeners();
        }
      }
    }, onError: (e) => debugPrint('TransitProvider cloud stations sync notice: $e'));

    // 3. Real-time Lines synchronization
    _linesSubscription = TransitSyncService.streamLines(cityId).listen((cloudLines) {
      if (cloudLines.isNotEmpty) {
        bool changed = false;
        final Map<String, MetroLine> map = {for (var l in _lines) l.id: l};
        for (var cl in cloudLines) {
          final local = map[cl.id];
          // Guardrail: Never let a truncated/degraded cloud document overwrite verified local data
          if (local != null && cl.stationIds.length < local.stationIds.length) {
            debugPrint('TransitProvider: Ignoring truncated cloud line ${cl.id} (${cl.stationIds.length} vs local ${local.stationIds.length})');
            continue;
          }
          map[cl.id] = cl;
          changed = true;
        }
        if (changed) {
          _lines = map.values.toList();
          _graphService = TransitGraphService(stations: _stations, lines: _lines);
          if (_originStation != null && _destinationStation != null) {
            computeRoutes();
          }
          notifyListeners();
        }
      }
    }, onError: (e) => debugPrint('TransitProvider cloud lines sync notice: $e'));

    // 4. Real-time Alerts synchronization
    _alertsSubscription = TransitSyncService.streamActiveAlerts(cityId).listen((cloudAlerts) {
      if (cloudAlerts.isNotEmpty) {
        _alerts = cloudAlerts;
        notifyListeners();
      }
    }, onError: (e) => debugPrint('TransitProvider cloud alerts sync notice: $e'));
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

  @override
  void dispose() {
    _stationsSubscription?.cancel();
    _linesSubscription?.cancel();
    _alertsSubscription?.cancel();
    _citiesSubscription?.cancel();
    super.dispose();
  }
}
