import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_do_it/app/data/remote_config_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/core/ads/ad_helper.dart';

class AdService {
  static RewardedInterstitialAd? _rewardedInterstitialAd;

  static Future<void> init() async {
    await MobileAds.instance.initialize();
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['CEEF47957310535EA6DDA54886009607']),
    );
    loadRewardedInterstitialAd();
  }

  static void loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadRewardedInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedInterstitialAd = null;
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedInterstitialAd = null;
        },
      ),
    );
  }

  static Future<void> showRewardedInterstitialAd({
    required BuildContext context,
    required void Function(RewardItem) onReward,
  }) async {
    final remoteConfigService = RemoteConfigService();
    final bool isAdEnabled = await remoteConfigService.getToggleRewardTaskAd();

    if (!isAdEnabled) {
      Utils().failureToast(
        'Ad feature temporarily disabled. Please try again later.',
        context,
      );
      return;
    }

    if (_rewardedInterstitialAd == null) {
      Utils().failureToast(
        'Ad not ready yet. Please try again shortly.',
        context,
      );
      loadRewardedInterstitialAd();
      return;
    }

    _rewardedInterstitialAd?.show(
      onUserEarnedReward: (ad, reward) => onReward(reward),
    );
    _rewardedInterstitialAd = null;
  }
}
