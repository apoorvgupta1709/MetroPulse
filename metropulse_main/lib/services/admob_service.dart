import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static bool adsGloballyEnabled = true; // Admin remote killswitch toggle
  static int interstitialFrequencyThreshold = 3;
  static int _routeCalculationsCount = 0;

  // Dynamic remote overrides from Firestore
  static String? customBannerAdUnitId;
  static String? customInterstitialAdUnitId;
  static String? customRewardedAdUnitId;

  // Real Production AdMob Unit IDs (defaults)
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (customBannerAdUnitId != null && customBannerAdUnitId!.isNotEmpty) {
      return customBannerAdUnitId!;
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-2281923791402266/6690061571';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (customInterstitialAdUnitId != null && customInterstitialAdUnitId!.isNotEmpty) {
      return customInterstitialAdUnitId!;
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-2281923791402266/8142744044';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (customRewardedAdUnitId != null && customRewardedAdUnitId!.isNotEmpty) {
      return customRewardedAdUnitId!;
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-2281923791402266/5937438449';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('MobileAds initialization skipped or failed: $e');
    }
  }

  // Preloaded Interstitial Ad instance
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoading = false;

  static void loadInterstitial() {
    if (kIsWeb || !adsGloballyEnabled || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }
    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('MetroPulse InterstitialAd failed to load: [Code ${error.code}] ${error.message}');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// Show interstitial after route calculation, frequency capped
  static void onRouteSearched({required bool isProUser, VoidCallback? onDismissed}) {
    if (isProUser || !adsGloballyEnabled) {
      onDismissed?.call();
      return;
    }

    _routeCalculationsCount++;
    if (_routeCalculationsCount >= interstitialFrequencyThreshold) {
      _routeCalculationsCount = 0;
      if (_interstitialAd != null) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _interstitialAd = null;
            loadInterstitial(); // preload next
            onDismissed?.call();
          },
          onAdFailedToShowFullScreenContent: (ad, err) {
            ad.dispose();
            _interstitialAd = null;
            loadInterstitial();
            onDismissed?.call();
          },
        );
        _interstitialAd!.show();
        return;
      }
    }
    onDismissed?.call();
    loadInterstitial();
  }

  /// Rewarded Ad for free users to unlock Exit Gates or Offline Map HD Export
  static void showRewardedAd({
    required bool isProUser,
    required VoidCallback onRewardUnlocked,
    VoidCallback? onFailed,
  }) {
    if (isProUser || !adsGloballyEnabled) {
      onRewardUnlocked();
      return;
    }

    if (kIsWeb) {
      onRewardUnlocked();
      return;
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              onRewardUnlocked(); // fallback graceful grant
            },
          );
          ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            onRewardUnlocked();
          });
        },
        onAdFailedToLoad: (err) {
          debugPrint('MetroPulse RewardedAd failed to load: [Code ${err.code}] ${err.message}');
          // If ad network fails, gracefully grant reward to preserve UX
          onRewardUnlocked();
        },
      ),
    );
  }
}
