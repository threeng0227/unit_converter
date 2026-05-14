import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';

class AdService {
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // ── Banner ────────────────────────────────────────────────────────────────
  static BannerAd createBanner({required void Function(Ad) onLoaded}) {
    return BannerAd(
      adUnitId: AppConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
          ad.dispose();
        },
      ),
    );
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────
  static void loadRewarded({
    required void Function(RewardedAd) onLoaded,
    required void Function() onFailed,
  }) {
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded failed: $error');
          onFailed();
        },
      ),
    );
  }
}

// ── App Open Ad ───────────────────────────────────────────────────────────────
class AppOpenAdManager {
  static AppOpenAd? _ad;
  static bool _loading = false;
  static DateTime? _loadTime;

  static bool get _isAdValid {
    if (_ad == null) return false;
    if (_loadTime == null) return false;
    // Ad expires after 4 hours
    return DateTime.now().difference(_loadTime!).inHours < 4;
  }

  static void load({bool showOnLoad = false}) {
    if (_loading || _isAdValid) return;
    _loading = true;
    AppOpenAd.load(
      adUnitId: AppConstants.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadTime = DateTime.now();
          _loading = false;
          debugPrint('AppOpenAd loaded');
          if (showOnLoad) show();
        },
        onAdFailedToLoad: (error) {
          _loading = false;
          debugPrint('AppOpenAd failed: $error');
        },
      ),
    );
  }

  static void show() {
    if (!_isAdValid) {
      load();
      return;
    }
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _ad = null;
        load(); // preload next
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _ad = null;
        load();
      },
    );
    _ad!.show();
  }
}
