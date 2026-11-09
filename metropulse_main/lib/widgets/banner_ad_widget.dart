import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/monetization_provider.dart';
import '../services/admob_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndLoadAd();
  }

  void _checkAndLoadAd() {
    final monetization = Provider.of<MonetizationProvider>(context, listen: false);
    if (monetization.isPro || !AdMobService.adsGloballyEnabled || kIsWeb) {
      _bannerAd?.dispose();
      _bannerAd = null;
      _isLoaded = false;
      return;
    }

    if (_bannerAd == null) {
      _bannerAd = BannerAd(
        adUnitId: AdMobService.bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            _bannerAd = null;
            if (mounted) {
              setState(() {
                _isLoaded = false;
              });
            }
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MonetizationProvider>(
      builder: (context, monetization, child) {
        if (monetization.isPro || !AdMobService.adsGloballyEnabled || kIsWeb) {
          return const SizedBox.shrink();
        }

        if (!_isLoaded || _bannerAd == null) {
          return Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Center(
              child: Text(
                'AdMob Banner Placeholder (Free Tier)',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: AdWidget(ad: _bannerAd!),
        );
      },
    );
  }
}
