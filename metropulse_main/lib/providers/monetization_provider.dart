import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/admob_service.dart';
import '../services/transit_sync_service.dart';

class MonetizationProvider extends ChangeNotifier {
  static const String _prefKeyIsPro = 'metropulse_is_prime_user';
  static const String _prefKeyAdsRemoved = 'metropulse_ads_removed';
  static const String _prefKeyUserEmail = 'metropulse_user_email';

  bool _isPro = false;
  bool _adsRemoved = false;
  String? _userEmail;

  // Dynamic Remote Pricing configuration
  int _currentPrice = 49;
  int _originalPrice = 149;
  int _discountPercent = 67;
  DateTime _discountExpiry = DateTime.now().add(const Duration(hours: 4, minutes: 28, seconds: 15));
  Timer? _countdownTimer;
  Duration _timeLeft = const Duration(hours: 4, minutes: 28, seconds: 15);
  StreamSubscription? _remoteConfigSub;

  bool get isPro => _isPro;
  bool get adsRemoved => _adsRemoved;
  String? get userEmail => _userEmail;
  int get currentPrice => _currentPrice;
  int get originalPrice => _originalPrice;
  int get discountPercent => _discountPercent;
  Duration get timeLeft => _timeLeft;

  MonetizationProvider() {
    _loadStoredPreferences();
    _startCountdown();
    _initRemoteConfigSync();
  }

  Future<void> _loadStoredPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_prefKeyIsPro) ?? false;
    _adsRemoved = prefs.getBool(_prefKeyAdsRemoved) ?? false;
    _userEmail = prefs.getString(_prefKeyUserEmail);
    if (_isPro) {
      AdMobService.adsGloballyEnabled = false;
    }
    notifyListeners();
  }

  void _initRemoteConfigSync() {
    _remoteConfigSub?.cancel();
    _remoteConfigSub = TransitSyncService.streamMonetizationConfig().listen((config) {
      if (config != null) {
        if (config['primePrice'] != null) {
          _currentPrice = (config['primePrice'] as num).toInt();
        }
        if (config['primeOriginalPrice'] != null) {
          _originalPrice = (config['primeOriginalPrice'] as num).toInt();
        }
        if (config['primeDiscountPercent'] != null) {
          _discountPercent = (config['primeDiscountPercent'] as num).toInt();
        }
        if (config['adsEnabled'] != null) {
          final adsEnabled = config['adsEnabled'] as bool;
          if (!_isPro) {
            AdMobService.adsGloballyEnabled = adsEnabled;
          }
        }
        notifyListeners();
      }
    }, onError: (e) => debugPrint('MonetizationProvider cloud config notice: $e'));
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (_discountExpiry.isAfter(now)) {
        _timeLeft = _discountExpiry.difference(now);
        notifyListeners();
      } else {
        _discountExpiry = DateTime.now().add(const Duration(hours: 6));
        _timeLeft = const Duration(hours: 6);
        notifyListeners();
      }
    });
  }

  /// Complete Prime purchase and bind permanently to user account
  Future<void> upgradeToPrime({
    required String paymentId,
    String? email,
    String? userId,
  }) async {
    _isPro = true;
    _adsRemoved = true;
    _userEmail = email ?? _userEmail;
    AdMobService.adsGloballyEnabled = false; // immediately silence all ads

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsPro, true);
    await prefs.setBool(_prefKeyAdsRemoved, true);
    if (_userEmail != null) {
      await prefs.setString(_prefKeyUserEmail, _userEmail!);
    }

    // Persist Prime status to user's Firestore record
    if (userId != null && userId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'isPrime': true,
          'primePaymentId': paymentId,
          'primeActivatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore Prime Sync Notice: $e');
      }
    }

    notifyListeners();
  }

  /// Restore purchases (checks local prefs and optionally Firestore)
  Future<bool> restorePurchase({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    bool pro = prefs.getBool(_prefKeyIsPro) ?? false;

    if (!pro && userId != null && userId.isNotEmpty) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (doc.exists && doc.data()?['isPrime'] == true) {
          pro = true;
          await prefs.setBool(_prefKeyIsPro, true);
          await prefs.setBool(_prefKeyAdsRemoved, true);
        }
      } catch (e) {
        debugPrint('Restore Prime Firestore Error: $e');
      }
    }

    if (pro) {
      _isPro = true;
      _adsRemoved = true;
      AdMobService.adsGloballyEnabled = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remoteConfigSub?.cancel();
    super.dispose();
  }
}
