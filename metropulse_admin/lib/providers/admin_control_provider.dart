import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/admin_config.dart';

class AdminCity {
  String id;
  String name;
  String currency;
  String country;
  int linesCount;
  int stationsCount;
  String mapStatus;

  AdminCity({
    required this.id,
    required this.name,
    required this.currency,
    required this.country,
    required this.linesCount,
    required this.stationsCount,
    this.mapStatus = '4K Vector Active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currencySymbol': currency,
      'country': country,
      'stateOrCountry': country,
      'linesCount': linesCount,
      'stationsCount': stationsCount,
      'rechargeUrl': 'https://www.dmrcsmartcard.com/',
      'centerLatitude': 28.6139,
      'centerLongitude': 77.2090,
    };
  }
}

class AdminLine {
  String id;
  String cityId;
  String name;
  String code;
  String colorHex;
  List<String> stationIds;

  AdminLine({
    required this.id,
    required this.cityId,
    required this.name,
    required this.code,
    required this.colorHex,
    required this.stationIds,
  });

  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityId': cityId,
      'name': name,
      'code': code,
      'colorHex': colorHex,
      'firstTrain': '05:30 AM',
      'lastTrain': '11:30 PM',
      'frequencyMinutes': 4,
      'stationIds': stationIds,
      'startStationName': '',
      'endStationName': '',
    };
  }

  factory AdminLine.fromMap(Map<String, dynamic> map, String id) {
    return AdminLine(
      id: id,
      cityId: map['cityId'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      colorHex: map['colorHex'] ?? '#2196F3',
      stationIds: List<String>.from(map['stationIds'] ?? []),
    );
  }
}

class AdminStation {
  String id;
  String cityId;
  String name;
  String hindiName;
  List<String> lineIds;
  bool isInterchange;
  double latitude;
  double longitude;
  List<String> gates;
  bool hasParking;
  bool hasEscalator;
  bool hasElevator;
  bool hasAtm;
  bool hasRestroom;

  AdminStation({
    required this.id,
    required this.cityId,
    required this.name,
    required this.hindiName,
    required this.lineIds,
    required this.isInterchange,
    required this.latitude,
    required this.longitude,
    required this.gates,
    this.hasParking = true,
    this.hasEscalator = true,
    this.hasElevator = true,
    this.hasAtm = true,
    this.hasRestroom = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityId': cityId,
      'name': name,
      'hindiName': hindiName,
      'lineIds': lineIds,
      'isInterchange': isInterchange,
      'latitude': latitude,
      'longitude': longitude,
      'gates': gates.map((g) => {'gateNumber': g.split(':').first.trim(), 'landmark': g, 'hasWheelchairAccess': true}).toList(),
      'facilities': {
        'hasParking': hasParking,
        'hasEscalator': hasEscalator,
        'hasElevator': hasElevator,
        'hasAtm': hasAtm,
        'hasRestroom': hasRestroom,
        'hasWifi': true,
      },
      'platformDirections': {for (var l in lineIds) l: 'Towards Destination, Platform 1 & 2'},
    };
  }

  factory AdminStation.fromMap(Map<String, dynamic> map, String id) {
    final rawGates = map['gates'] as List? ?? [];
    final gateList = rawGates.map((g) {
      if (g is Map) {
        return '${g['gateNumber'] ?? 'Gate'}: ${g['landmark'] ?? ''}';
      }
      return g.toString();
    }).toList();

    final fac = Map<String, dynamic>.from(map['facilities'] ?? {});

    return AdminStation(
      id: id,
      cityId: map['cityId'] ?? '',
      name: map['name'] ?? '',
      hindiName: map['hindiName'] ?? '',
      lineIds: List<String>.from(map['lineIds'] ?? []),
      isInterchange: map['isInterchange'] ?? false,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      gates: gateList,
      hasParking: fac['hasParking'] ?? true,
      hasEscalator: fac['hasEscalator'] ?? true,
      hasElevator: fac['hasElevator'] ?? true,
      hasAtm: fac['hasAtm'] ?? true,
      hasRestroom: fac['hasRestroom'] ?? true,
    );
  }
}

class AdminAlert {
  String id;
  String cityName;
  String lineName;
  String title;
  String severity;
  DateTime time;
  bool isActive;

  AdminAlert({
    required this.id,
    required this.cityName,
    required this.lineName,
    required this.title,
    required this.severity,
    required this.time,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cityId': 'delhi_ncr',
      'lineId': '',
      'lineName': lineName,
      'headline': title,
      'details': '$severity priority update for $lineName ($cityName)',
      'severity': severity.toLowerCase(),
      'timestamp': time.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AdminAlert.fromMap(Map<String, dynamic> map, String id) {
    return AdminAlert(
      id: id,
      cityName: map['cityName'] ?? 'Delhi NCR',
      lineName: map['lineName'] ?? 'Metro',
      title: map['headline'] ?? map['title'] ?? '',
      severity: (map['severity'] ?? 'normal').toString().toUpperCase(),
      time: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }
}

class AdminControlProvider extends ChangeNotifier {
  final MonetizationConfig _config = MonetizationConfig();
  bool _isSyncing = false;
  String _syncStatusMessage = '';

  bool get isSyncing => _isSyncing;
  String get syncStatusMessage => _syncStatusMessage;

  final List<AdminCity> _cities = [
    AdminCity(id: 'delhi_ncr', name: 'Delhi NCR', currency: '₹', country: 'India', linesCount: 6, stationsCount: 20),
    AdminCity(id: 'mumbai', name: 'Mumbai Metro', currency: '₹', country: 'India', linesCount: 2, stationsCount: 11),
    AdminCity(id: 'bengaluru', name: 'Bengaluru Namma Metro', currency: '₹', country: 'India', linesCount: 2, stationsCount: 11),
    AdminCity(id: 'dubai', name: 'Dubai Metro', currency: 'AED', country: 'UAE', linesCount: 2, stationsCount: 12),
    AdminCity(id: 'singapore', name: 'Singapore MRT', currency: 'S\$', country: 'Singapore', linesCount: 2, stationsCount: 7),
    AdminCity(id: 'london', name: 'London Underground', currency: '£', country: 'UK', linesCount: 2, stationsCount: 9),
  ];

  final List<AdminLine> _lines = [
    AdminLine(
      id: 'yellow',
      cityId: 'delhi_ncr',
      name: 'Yellow Line',
      code: 'YL',
      colorHex: '#FBC02D',
      stationIds: ['del_samaypur_badli', 'del_kashmere_gate', 'del_rajiv_chowk', 'del_aiims', 'del_huda_city_centre'],
    ),
    AdminLine(
      id: 'blue',
      cityId: 'delhi_ncr',
      name: 'Blue Line',
      code: 'BL',
      colorHex: '#1976D2',
      stationIds: ['del_dwarka_sec_21', 'del_janakpuri_west', 'del_rajiv_chowk', 'del_botanical_garden', 'del_noida_electronic_city'],
    ),
    AdminLine(
      id: 'red',
      cityId: 'delhi_ncr',
      name: 'Red Line',
      code: 'RD',
      colorHex: '#D32F2F',
      stationIds: ['del_rithala', 'del_kashmere_gate', 'del_shaheed_sthal'],
    ),
  ];

  final List<AdminStation> _stations = [
    AdminStation(
      id: 'del_rajiv_chowk',
      cityId: 'delhi_ncr',
      name: 'Rajiv Chowk (Connaught Place)',
      hindiName: 'राजीव चौक',
      lineIds: ['yellow', 'blue'],
      isInterchange: true,
      latitude: 28.6328,
      longitude: 77.2195,
      gates: ['Gate 1: CP B-Block', 'Gate 2: Regal Cinema', 'Gate 3: Palika Bazar'],
    ),
    AdminStation(
      id: 'del_kashmere_gate',
      cityId: 'delhi_ncr',
      name: 'Kashmere Gate ISBT',
      hindiName: 'कश्मीरी गेट',
      lineIds: ['yellow', 'red'],
      isInterchange: true,
      latitude: 28.6675,
      longitude: 77.2285,
      gates: ['Gate 1: ISBT Bus Terminal', 'Gate 2: Old Delhi Rly Station'],
    ),
    AdminStation(
      id: 'del_aiims',
      cityId: 'delhi_ncr',
      name: 'AIIMS',
      hindiName: 'एम्स',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.5684,
      longitude: 77.2081,
      gates: ['Gate 1: AIIMS Hospital OPD', 'Gate 2: Safdarjung Hospital'],
    ),
    AdminStation(
      id: 'del_huda_city_centre',
      cityId: 'delhi_ncr',
      name: 'Millennium City Centre Gurugram',
      hindiName: 'मिलेनियम सिटी सेंटर',
      lineIds: ['yellow'],
      isInterchange: false,
      latitude: 28.4593,
      longitude: 77.0725,
      gates: ['Gate 1: Fortis Hospital', 'Gate 2: Sector 29 F&B Hub'],
    ),
  ];

  final List<AdminAlert> _alerts = [
    AdminAlert(
      id: 'alt_1',
      cityName: 'Delhi NCR',
      lineName: 'Yellow Line',
      title: 'Crowd regulation at Rajiv Chowk & Kashmere Gate',
      severity: 'Normal',
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      isActive: true,
    ),
  ];

  MonetizationConfig get config => _config;
  List<AdminCity> get cities => _cities;
  List<AdminLine> get lines => _lines;
  List<AdminStation> get stations => _stations;
  List<AdminAlert> get alerts => _alerts;

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('Admin Firestore instance check notice: $e');
    }
    return null;
  }

  AdminControlProvider() {
    _initCloudListeners();
  }

  void _initCloudListeners() {
    final db = _firestore;
    if (db == null) return;
    try {
      // Listen to service alerts from Firestore
      db.collection('service_alerts').snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final cloudAlerts = snapshot.docs.map((doc) => AdminAlert.fromMap(doc.data(), doc.id)).toList();
          final Map<String, AdminAlert> map = {for (var a in _alerts) a.id: a};
          for (var ca in cloudAlerts) {
            map[ca.id] = ca;
          }
          _alerts.clear();
          _alerts.addAll(map.values);
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Admin service alerts sync notice: $e'));

      // Listen to monetization config
      db.collection('app_config').doc('monetization').snapshots().listen((doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['adsEnabled'] != null) _config.adsEnabled = data['adsEnabled'];
          if (data['interstitialFrequency'] != null) _config.interstitialFrequency = data['interstitialFrequency'];
          if (data['primePrice'] != null) _config.primePrice = data['primePrice'];
          if (data['primeOriginalPrice'] != null) _config.primeOriginalPrice = data['primeOriginalPrice'];
          if (data['primeDiscountPercent'] != null) _config.primeDiscountPercent = data['primeDiscountPercent'];
          if (data['countdownHours'] != null) _config.countdownHours = data['countdownHours'];
          notifyListeners();
        }
      }, onError: (e) => debugPrint('Admin monetization config notice: $e'));
    } catch (e) {
      debugPrint('AdminControlProvider init notice: $e');
    }
  }

  // Add a new station directly from Admin UI and push live to Firestore
  Future<void> addStation({
    required String cityId,
    required String name,
    required String hindiName,
    required String lineId,
    required double latitude,
    required double longitude,
    required bool isInterchange,
    required List<String> gates,
    bool hasParking = true,
    bool hasEscalator = true,
    bool hasElevator = true,
    bool hasAtm = true,
    bool hasRestroom = true,
  }) async {
    final id = '${cityId.substring(0, 3)}_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

    final station = AdminStation(
      id: id,
      cityId: cityId,
      name: name,
      hindiName: hindiName,
      lineIds: [lineId],
      isInterchange: isInterchange,
      latitude: latitude,
      longitude: longitude,
      gates: gates,
      hasParking: hasParking,
      hasEscalator: hasEscalator,
      hasElevator: hasElevator,
      hasAtm: hasAtm,
      hasRestroom: hasRestroom,
    );

    _stations.add(station);

    // Append to line's station sequence
    final lineIndex = _lines.indexWhere((l) => l.id == lineId);
    if (lineIndex != -1) {
      _lines[lineIndex].stationIds.add(id);
    }

    // Update city station count
    final cityIndex = _cities.indexWhere((c) => c.id == cityId);
    if (cityIndex != -1) {
      _cities[cityIndex].stationsCount++;
    }

    notifyListeners();

    // Push live to Cloud Firestore
    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('cities')
            .doc(cityId)
            .collection('stations')
            .doc(id)
            .set(station.toMap());

        await db
            .collection('cities')
            .doc(cityId)
            .collection('lines')
            .doc(lineId)
            .set({
          'stationIds': FieldValue.arrayUnion([id])
        }, SetOptions(merge: true));

        debugPrint('Successfully published station $id to Cloud Firestore');
      }
    } catch (e) {
      debugPrint('Error writing station to Firestore: $e');
    }
  }

  // Delete a station
  Future<void> deleteStation(String stationId, {String cityId = 'delhi_ncr'}) async {
    _stations.removeWhere((s) => s.id == stationId);
    for (var l in _lines) {
      l.stationIds.remove(stationId);
    }
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('cities')
            .doc(cityId)
            .collection('stations')
            .doc(stationId)
            .delete();
      }
    } catch (e) {
      debugPrint('Error deleting station from Firestore: $e');
    }
  }

  // Add a new line directly from Admin UI
  Future<void> addLine({
    required String cityId,
    required String name,
    required String code,
    required String colorHex,
  }) async {
    final id = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final line = AdminLine(
      id: id,
      cityId: cityId,
      name: name,
      code: code,
      colorHex: colorHex,
      stationIds: [],
    );

    _lines.add(line);

    final cityIndex = _cities.indexWhere((c) => c.id == cityId);
    if (cityIndex != -1) {
      _cities[cityIndex].linesCount++;
    }

    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('cities')
            .doc(cityId)
            .collection('lines')
            .doc(id)
            .set(line.toMap());
      }
    } catch (e) {
      debugPrint('Error writing line to Firestore: $e');
    }
  }

  // Delete a line
  Future<void> deleteLine(String lineId, {String cityId = 'delhi_ncr'}) async {
    _lines.removeWhere((l) => l.id == lineId);
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('cities')
            .doc(cityId)
            .collection('lines')
            .doc(lineId)
            .delete();
      }
    } catch (e) {
      debugPrint('Error deleting line: $e');
    }
  }

  // Toggle AdMob Killswitch
  Future<void> toggleAds(bool enabled) async {
    _config.adsEnabled = enabled;
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('app_config')
            .doc('monetization')
            .set({'adsEnabled': enabled}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error updating ads config: $e');
    }
  }

  // Set Interstitial frequency
  Future<void> setInterstitialFrequency(int count) async {
    _config.interstitialFrequency = count;
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('app_config')
            .doc('monetization')
            .set({'interstitialFrequency': count}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error updating frequency: $e');
    }
  }

  // Update Dynamic Prime Pricing
  Future<void> updatePrimePricing({
    required int price,
    required int originalPrice,
    required int discountPercent,
    required int countdownHours,
  }) async {
    _config.primePrice = price;
    _config.primeOriginalPrice = originalPrice;
    _config.primeDiscountPercent = discountPercent;
    _config.countdownHours = countdownHours;
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('app_config')
            .doc('monetization')
            .set(_config.toMap(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error updating dynamic pricing: $e');
    }
  }

  // Add / Edit Service Alert
  Future<void> broadcastAlert({
    required String cityName,
    required String lineName,
    required String title,
    required String severity,
  }) async {
    final alert = AdminAlert(
      id: 'alt_${DateTime.now().millisecondsSinceEpoch}',
      cityName: cityName,
      lineName: lineName,
      title: title,
      severity: severity,
      time: DateTime.now(),
      isActive: true,
    );

    _alerts.insert(0, alert);
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('service_alerts')
            .doc(alert.id)
            .set(alert.toMap());
      }
    } catch (e) {
      debugPrint('Error broadcasting alert: $e');
    }
  }

  Future<void> toggleAlertStatus(String id) async {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].isActive = !_alerts[index].isActive;
      final newStatus = _alerts[index].isActive;
      notifyListeners();

      try {
        final db = _firestore;
        if (db != null) {
          await db
              .collection('service_alerts')
              .doc(id)
              .update({'isActive': newStatus});
        }
      } catch (e) {
        debugPrint('Error toggling alert status: $e');
      }
    }
  }

  Future<void> deleteAlert(String id) async {
    _alerts.removeWhere((a) => a.id == id);
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('service_alerts')
            .doc(id)
            .delete();
      }
    } catch (e) {
      debugPrint('Error deleting alert: $e');
    }
  }

  Future<void> addCity({
    required String name,
    required String currency,
    required String country,
  }) async {
    final id = name.toLowerCase().replaceAll(' ', '_');
    final city = AdminCity(
      id: id,
      name: name,
      currency: currency,
      country: country,
      linesCount: 1,
      stationsCount: 10,
    );
    _cities.add(city);
    notifyListeners();

    try {
      final db = _firestore;
      if (db != null) {
        await db
            .collection('cities')
            .doc(id)
            .set(city.toMap());
      }
    } catch (e) {
      debugPrint('Error adding city: $e');
    }
  }

  /// Master 1-Tap Cloud Seeding: Syncs all default cities, lines, stations, and config to Cloud Firestore
  Future<void> seedInitialDataToCloud() async {
    _isSyncing = true;
    _syncStatusMessage = 'Seeding initial transit data to Cloud Firestore...';
    notifyListeners();

    try {
      final db = _firestore;
      if (db == null) {
        _syncStatusMessage = 'Firebase not initialized yet.';
        return;
      }

      // 1. Upload monetization config
      await db.collection('app_config').doc('monetization').set(_config.toMap());

      // 2. Upload cities
      for (final city in _cities) {
        await db.collection('cities').doc(city.id).set(city.toMap());
      }

      // 3. Upload lines
      for (final line in _lines) {
        await db
            .collection('cities')
            .doc(line.cityId)
            .collection('lines')
            .doc(line.id)
            .set(line.toMap());
      }

      // 4. Upload stations
      for (final station in _stations) {
        await db
            .collection('cities')
            .doc(station.cityId)
            .collection('stations')
            .doc(station.id)
            .set(station.toMap());
      }

      // 5. Upload initial service alert
      for (final alert in _alerts) {
        await db.collection('service_alerts').doc(alert.id).set(alert.toMap());
      }

      _syncStatusMessage = 'Cloud Sync Successful: All data synced to Firebase!';
    } catch (e) {
      _syncStatusMessage = 'Cloud sync notice: $e';
      debugPrint('Seed data error: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
