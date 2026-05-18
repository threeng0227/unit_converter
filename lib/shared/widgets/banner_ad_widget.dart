import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unit_converter_pro/shared/ads/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ad = AdService.createBanner(onLoaded: (ad) {
      if (mounted) setState(() => _loaded = true);
    });
    _ad!.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  // Standard banner height — always reserved to avoid layout jumps
  static const double _bannerHeight = 50.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: _bannerHeight,
        child: _loaded && _ad != null
            ? Center(
                child: SizedBox(
                  height: _ad!.size.height.toDouble(),
                  width: _ad!.size.width.toDouble(),
                  child: AdWidget(ad: _ad!),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
