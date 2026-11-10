import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/admob_service.dart';
import '../services/auth_service.dart';
import '../services/transit_sync_service.dart';

class MonetizationProvider extends ChangeNotifier {
  static const String _prefKeyIsPro = 'metropulse_is_prime_user';
  static const String _prefKeyAdsRemoved = 'metropulse_ads_removed';
  static const String _prefKeyUserEmail = 'metropulse_user_email';
  static const String _prefKeyUserId = 'metropulse_prime_user_id';

  bool _isPro = false;
  bool _adsRemoved = false;
  String? _userEmail;
  String? _userId;

  // Razorpay Gateway Key (defaults to official test key, overridable from Firestore)
  String _razorpayKeyId = 'rzp_test_1DP5mmOlF5G5ag';

  // Dynamic Remote Pricing configuration
  int _currentPrice = 49;
  int _originalPrice = 149;
  int _discountPercent = 67;
  DateTime _discountExpiry = DateTime.now().add(const Duration(hours: 4, minutes: 28, seconds: 15));
  Timer? _countdownTimer;
  Duration _timeLeft = const Duration(hours: 4, minutes: 28, seconds: 15);
  StreamSubscription? _remoteConfigSub;
  StreamSubscription? _authSub;

  bool get isPro => _isPro;
  bool get adsRemoved => _adsRemoved;
  String? get userEmail => _userEmail;
  String? get userId => _userId;
  String get razorpayKeyId => _razorpayKeyId;
  int get currentPrice => _currentPrice;
  int get originalPrice => _originalPrice;
  int get discountPercent => _discountPercent;
  Duration get timeLeft => _timeLeft;

  MonetizationProvider() {
    _startCountdown();
    _initRemoteConfigSync();
    _initAuthSync();
  }

  void _initAuthSync() {
    _authSub?.cancel();
    _authSub = AuthService.authStateChanges.listen((user) {
      syncUserEntitlement(user?.uid, user?.email);
    });
    // Initial check on construction
    final currentUser = AuthService.currentUser;
    syncUserEntitlement(currentUser?.uid, currentUser?.email);
  }

  /// Sync user entitlement with Firestore (ensures unpaying users never get Prime for free)
  Future<void> syncUserEntitlement(String? uid, String? email) async {
    _userId = uid;
    _userEmail = email;

    if (uid == null || uid.isEmpty) {
      // Free guest/commuter tier: ads enabled, pro features disabled
      _isPro = false;
      _adsRemoved = false;
      AdMobService.adsGloballyEnabled = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyIsPro, false);
      await prefs.setBool(_prefKeyAdsRemoved, false);
      await prefs.remove(_prefKeyUserId);
      notifyListeners();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final bool hasPurchased = doc.exists && doc.data()?['isPrime'] == true;

      _isPro = hasPurchased;
      _adsRemoved = hasPurchased;
      AdMobService.adsGloballyEnabled = !hasPurchased; // Ads active if not Prime!

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyIsPro, hasPurchased);
      await prefs.setBool(_prefKeyAdsRemoved, hasPurchased);
      await prefs.setString(_prefKeyUserId, uid);
      if (email != null) {
        await prefs.setString(_prefKeyUserEmail, email);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Sync user entitlement notice: $e');
      // If offline, check if local storage had this user verified
      final prefs = await SharedPreferences.getInstance();
      final cachedUid = prefs.getString(_prefKeyUserId);
      if (cachedUid == uid) {
        final cachedPro = prefs.getBool(_prefKeyIsPro) ?? false;
        _isPro = cachedPro;
        _adsRemoved = cachedPro;
        AdMobService.adsGloballyEnabled = !cachedPro;
      } else {
        _isPro = false;
        _adsRemoved = false;
        AdMobService.adsGloballyEnabled = true;
      }
      notifyListeners();
    }
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
        if (config['razorpayKeyId'] != null && (config['razorpayKeyId'] as String).isNotEmpty) {
          _razorpayKeyId = (config['razorpayKeyId'] as String).trim();
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

  /// Complete Prime purchase via Razorpay and bind permanently to user account
  Future<void> upgradeToPrime({
    required String paymentId,
    String? email,
    String? userId,
  }) async {
    _isPro = true;
    _adsRemoved = true;
    _userEmail = email ?? _userEmail;
    _userId = userId ?? _userId;
    AdMobService.adsGloballyEnabled = false; // immediately silence all ads

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsPro, true);
    await prefs.setBool(_prefKeyAdsRemoved, true);
    if (_userEmail != null) {
      await prefs.setString(_prefKeyUserEmail, _userEmail!);
    }
    if (_userId != null) {
      await prefs.setString(_prefKeyUserId, _userId!);
    }

    // Persist Prime status to user's Firestore record
    final uid = userId ?? AuthService.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
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

  /// Restore purchases (checks Firestore for logged-in account)
  Future<bool> restorePurchase({String? userId}) async {
    final uid = userId ?? AuthService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return false;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data()?['isPrime'] == true) {
        _isPro = true;
        _adsRemoved = true;
        AdMobService.adsGloballyEnabled = false;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefKeyIsPro, true);
        await prefs.setBool(_prefKeyAdsRemoved, true);
        await prefs.setString(_prefKeyUserId, uid);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Restore Prime Firestore Error: $e');
    }
    return false;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remoteConfigSub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
