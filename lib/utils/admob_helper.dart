import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobHelper {
  final String nativeAdUnitId;
  final String nativeFactoryId;
  final String rewardAdUnitId;

  NativeAd? _nativeAd;
  RewardedAd? _rewardedAd;

  AdMobHelper({required this.nativeAdUnitId, required this.nativeFactoryId, required this.rewardAdUnitId});

  Future<NativeAd> createNativeAd() {
    final Completer<NativeAd> completer = Completer<NativeAd>();

    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: nativeFactoryId,
      request: AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) => completer.complete(ad as NativeAd),
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('NativeAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _nativeAd!.load();

    return completer.future;
  }

  void loadRewardAd() {
    RewardedAd.load(
      adUnitId: rewardAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRewardAd() {
    _rewardedAd?.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: $reward');
        // Handle reward here
      },
    );
  }

  void dispose() {
    _nativeAd?.dispose();
    _rewardedAd?.dispose();
  }
}
