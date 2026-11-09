import 'dart:async';
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
  bool _isGoogleAuthenticated = false;

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
  bool get isGoogleAuthenticated => _isGoogleAuthenticated;
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
    if (_userEmail != null && _userEmail!.isNotEmpty) {
      _isGoogleAuthenticated = true;
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
        // Reset timer loop for ongoing urgency
        _discountExpiry = DateTime.now().add(const Duration(hours: 6));
        _timeLeft = const Duration(hours: 6);
        notifyListeners();
      }
    });
  }

  /// On-Demand Google Authentication (Triggered ONLY when user claims prime)
  Future<bool> signInWithGoogleOnDemand({String mockEmail = 'commuter.apoorv@gmail.com'}) async {
    // Zero-friction: prompts only when claiming prime pass
    _userEmail = mockEmail;
    _isGoogleAuthenticated = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyUserEmail, mockEmail);
    notifyListeners();
    return true;
  }

  /// Complete Razorpay Prime purchase and unlock all lifetime perks
  Future<void> upgradeToPrime({required String paymentId}) async {
    _isPro = true;
    _adsRemoved = true;
    AdMobService.adsGloballyEnabled = false; // immediately silence all ads

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyIsPro, true);
    await prefs.setBool(_prefKeyAdsRemoved, true);

    notifyListeners();
  }

  /// Restore purchases
  Future<bool> restorePurchase() async {
    final prefs = await SharedPreferences.getInstance();
    final pro = prefs.getBool(_prefKeyIsPro) ?? false;
    if (pro) {
      _isPro = true;
      _adsRemoved = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Remote config update (e.g. from Admin app sync)
  void updateRemotePricing({required int price, required int original, required int discount}) {
    _currentPrice = price;
    _originalPrice = original;
    _discountPercent = discount;
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _remoteConfigSub?.cancel();
    super.dispose();
  }
}
