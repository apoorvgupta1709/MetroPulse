import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/city.dart';
import '../models/metro_line.dart';
import '../models/service_alert.dart';
import '../models/station.dart';

class TransitSyncService {
  static FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (e) {
      debugPrint('Firestore instance check notice: $e');
    }
    return null;
  }

  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    try {
      final db = _firestore;
      if (db != null) {
        db.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        _initialized = true;
        debugPrint('MetroPulse TransitSyncService: Firestore offline caching enabled.');
      }
    } catch (e) {
      debugPrint('TransitSyncService init notice: $e');
    }
  }

  /// Listen to real-time stations for a city
  static Stream<List<Station>> streamStations(String cityId) {
    final db = _firestore;
    if (db == null) return const Stream.empty();

    return db
        .collection('cities')
        .doc(cityId)
        .collection('stations')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Station.fromMap(data);
      }).toList();
    }).handleError((error) {
      debugPrint('Firestore streamStations error for $cityId: $error');
      return <Station>[];
    });
  }

  /// Listen to real-time metro lines for a city
  static Stream<List<MetroLine>> streamLines(String cityId) {
    final db = _firestore;
    if (db == null) return const Stream.empty();

    return db
        .collection('cities')
        .doc(cityId)
        .collection('lines')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MetroLine.fromMap(data);
      }).toList();
    }).handleError((error) {
      debugPrint('Firestore streamLines error for $cityId: $error');
      return <MetroLine>[];
    });
  }

  /// Listen to live service delay alerts
  static Stream<List<ServiceAlert>> streamActiveAlerts(String cityId) {
    final db = _firestore;
    if (db == null) return const Stream.empty();

    return db
        .collection('service_alerts')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ServiceAlert.fromMap(data);
          })
          .where((a) => a.cityId.isEmpty || a.cityId == cityId)
          .toList();
    }).handleError((error) {
      debugPrint('Firestore streamActiveAlerts error: $error');
      return <ServiceAlert>[];
    });
  }

  /// Listen to remote dynamic monetization config (AdMob switch, Prime pricing)
  static Stream<Map<String, dynamic>?> streamMonetizationConfig() {
    final db = _firestore;
    if (db == null) return const Stream.empty();

    return db
        .collection('app_config')
        .doc('monetization')
        .snapshots()
        .map((doc) => doc.data())
        .handleError((error) {
      debugPrint('Firestore streamMonetizationConfig error: $error');
      return null;
    });
  }

  /// Listen to dynamic cities added from Admin
  static Stream<List<City>> streamCities() {
    final db = _firestore;
    if (db == null) return const Stream.empty();

    return db
        .collection('cities')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return City.fromMap(data);
      }).toList();
    }).handleError((error) {
      debugPrint('Firestore streamCities error: $error');
      return <City>[];
    });
  }
}
