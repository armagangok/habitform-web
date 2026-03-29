import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/debug_constants.dart';
import '../../../core/core.dart';
import '../../../models/user_defaults/user_defaults.dart';
import '../../../services/sync_service.dart';
import '../models/paywall_state.dart';

/// Subscription state for the web app: Firestore + local cache only (no store SDK).
final purchaseProvider = AsyncNotifierProvider<PurchaseNotifier, PaywallState>(() {
  return PurchaseNotifier();
});

class PurchaseNotifier extends AsyncNotifier<PaywallState> {
  final HiveHelper _hiveHelper = HiveHelper.shared;

  @override
  Future<PaywallState> build() async {
    state = const AsyncValue.loading();

    try {
      if (KDebug.purchaseDebugMode) {
        LogHelper.shared.debugPrint('Running in purchase debug mode');
        final currentDefaults = await _getUserDefaults() ?? UserDefaults();
        await _saveUserDefaults(currentDefaults.copyWith(isPro: true));
        return const PaywallState(isSubscriptionActive: true);
      }

      return await _paywallStateFromRemoteOrCache();
    } catch (e) {
      LogHelper.shared.debugPrint('Error initializing purchase state: $e');

      var isPro = (await _getUserDefaults())?.isPro ?? false;
      if (!isPro && FirebaseAuth.instance.currentUser != null) {
        final userData = await SyncService().getUserSubscription();
        if (userData != null) {
          isPro = userData['isSubscribed'] as bool? ?? false;
          if (isPro) {
            final currentDefaults = await _getUserDefaults() ?? UserDefaults();
            await _saveUserDefaults(currentDefaults.copyWith(isPro: true));
          }
        }
      }

      return PaywallState(isSubscriptionActive: isPro);
    }
  }

  Future<UserDefaults?> _getUserDefaults() async {
    try {
      return _hiveHelper.getData<UserDefaults>(
        HiveBoxes.userDefaultsBox,
        HiveKeys.userDefaultsKey,
      );
    } catch (e) {
      LogHelper.shared.debugPrint('Error getting user defaults: $e');
      return null;
    }
  }

  Future<void> _saveUserDefaults(UserDefaults userDefaults) async {
    try {
      await _hiveHelper.putData(
        HiveBoxes.userDefaultsBox,
        HiveKeys.userDefaultsKey,
        userDefaults,
      );
    } catch (e) {
      LogHelper.shared.debugPrint('Error saving user defaults: $e');
    }
  }

  Future<PaywallState> _paywallStateFromRemoteOrCache() async {
    var isPro = (await _getUserDefaults())?.isPro ?? false;
    if (!isPro && FirebaseAuth.instance.currentUser != null) {
      final userData = await SyncService().getUserSubscription();
      if (userData != null) {
        isPro = userData['isSubscribed'] as bool? ?? false;
        if (isPro) {
          final currentDefaults = await _getUserDefaults() ?? UserDefaults();
          await _saveUserDefaults(currentDefaults.copyWith(isPro: true));
        }
      }
    }
    return PaywallState(isSubscriptionActive: isPro);
  }

  Future<void> checkSubscriptionStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      if (KDebug.purchaseDebugMode) {
        final currentDefaults = await _getUserDefaults() ?? UserDefaults();
        await _saveUserDefaults(currentDefaults.copyWith(isPro: true));
        return const PaywallState(isSubscriptionActive: true);
      }
      return _paywallStateFromRemoteOrCache();
    });
  }

  Future<void> presentPaywall({
    required bool isFromOnboarding,
    bool isFromSettings = false,
  }) async {
    await checkSubscriptionStatus();
    final isActive = state.valueOrNull?.isSubscriptionActive ?? false;

    if (isFromOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.navigateAndClear(path: KRoute.homePage);
      });
      if (!isActive) {
        AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_webContinueFreeTier.tr());
      }
      return;
    }

    if (isFromSettings) {
      if (!isActive) {
        AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_webPurchaseOnMobile.tr());
      }
      return;
    }

    if (!isActive) {
      AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_webPurchaseOnMobile.tr());
    }
    navigator.pop();
  }

  Future<void> presentCustomerCenter() async {
    await checkSubscriptionStatus();
    AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_webPurchaseOnMobile.tr());
  }

  Future<void> restorePurchases(bool isFromOnboarding, {bool isFromSettings = false}) async {
    final previous = state.valueOrNull;
    if (previous == null) return;

    state = AsyncValue.data(previous.copyWith(isRestoring: true));

    await checkSubscriptionStatus();

    final next = state.valueOrNull;
    final isActive = next?.isSubscriptionActive ?? false;
    if (next != null) {
      state = AsyncValue.data(next.copyWith(isRestoring: false, isRestoreSuccess: isActive));
    }

    if (isFromOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.navigateAndClear(path: KRoute.homePage);
      });
      AppFlushbar.shared.successFlushbar(
        isActive ? LocaleKeys.subscription_restoreSuccessful.tr() : LocaleKeys.subscription_webContinueFreeTier.tr(),
      );
      return;
    }

    AppFlushbar.shared.successFlushbar(
      isActive ? LocaleKeys.subscription_restoreSuccessful.tr() : LocaleKeys.subscription_webPurchaseOnMobile.tr(),
    );
    if (isFromSettings && isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigator.navigateAndClear(path: KRoute.homePage);
      });
    }
  }

  Future<void> copyCustomerId() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: uid));
        AppFlushbar.shared.successFlushbar('Account ID copied\nID: $uid');
      } else {
        AppFlushbar.shared.warningFlushbar('Account ID is not available');
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error copying account ID: $e');
      AppFlushbar.shared.errorFlushbar('Failed to copy account ID');
    }
  }
}
