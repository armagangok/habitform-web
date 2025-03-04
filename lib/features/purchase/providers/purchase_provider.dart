import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/debug_constants.dart';
import '../../../core/core.dart';
import '../../../models/user_defaults/user_defaults.dart';
import '../models/paywall_state.dart';
import '../purchase.dart';

/// Main paywall provider that handles subscription state
final purchaseProvider = AsyncNotifierProvider<PurchaseNotifier, PaywallState>(() {
  return PurchaseNotifier();
});

class PurchaseNotifier extends AsyncNotifier<PaywallState> {
  final HiveHelper _hiveHelper = HiveHelper.shared;

  @override
  Future<PaywallState> build() async {
    state = const AsyncValue.loading();

    try {
      // Debug modunda abonelik durumunu override et
      if (KDebug.purchaseDebugMode) {
        LogHelper.shared.debugPrint('Running in purchase debug mode');
        // Mevcut UserDefaults'ı al ve güncelle
        final currentDefaults = await _getUserDefaults() ?? UserDefaults();
        await _saveUserDefaults(currentDefaults.copyWith(isPro: true));

        // Debug modunda bile API çağrıları yaparak UI için gerekli verileri al
        try {
          final customerInfo = await Purchases.getCustomerInfo();
          final offerings = await Purchases.getOfferings();

          return PaywallState(
            isSubscriptionActive: true, // Debug modunda aboneliği aktif olarak zorla
            customerInfo: customerInfo,
            offerings: offerings,
          );
        } catch (e) {
          // API çağrıları başarısız olursa sadece aktif abonelik ile devam et
          LogHelper.shared.debugPrint('Failed to get RevenueCat data in debug mode: $e');
          return PaywallState(
            isSubscriptionActive: true, // Debug modunda aboneliği aktif olarak zorla
          );
        }
      }

      // İnternet bağlantısı varsa, normal akışa devam et
      // Önce mevcut müşteri bilgilerini al
      final customerInfo = await Purchases.getCustomerInfo();
      final offerings = await Purchases.getOfferings();

      // Abonelik durumunu kontrol et
      final isActive = customerInfo.entitlements.active.isNotEmpty;

      // Mevcut UserDefaults'ı al ve güncelle
      final currentDefaults = await _getUserDefaults() ?? UserDefaults();
      await _saveUserDefaults(currentDefaults.copyWith(isPro: isActive));

      return PaywallState(
        offerings: offerings,
        customerInfo: customerInfo,
        isSubscriptionActive: isActive,
      );
    } catch (e) {
      LogHelper.shared.debugPrint('Error initializing purchase state: $e');

      // Hata durumunda UserDefaults'dan pro durumunu kontrol et
      final userDefaults = await _getUserDefaults();

      // Eğer önceki state varsa, offerings ve customerInfo'yu koru
      final previousState = state.valueOrNull;
      return PaywallState(
        isSubscriptionActive: userDefaults?.isPro ?? false,
        offerings: previousState?.offerings,
        customerInfo: previousState?.customerInfo,
      );
    }
  }

  /// UserDefaults'dan kullanıcı ayarlarını al
  Future<UserDefaults?> _getUserDefaults() async {
    try {
      final userDefaults = _hiveHelper.getData<UserDefaults>(
        HiveBoxes.userDefaultsBox,
        HiveKeys.userDefaultsKey,
      );
      return userDefaults;
    } catch (e) {
      LogHelper.shared.debugPrint('Error getting user defaults: $e');
      return null;
    }
  }

  /// Kullanıcı ayarlarını kaydet
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

  /// Checks and updates the current subscription status
  Future<void> checkSubscriptionStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Debug modunda abonelik durumunu override et
      if (KDebug.purchaseDebugMode) {
        LogHelper.shared.debugPrint('Checking subscription status in debug mode');

        // Mevcut UserDefaults'ı al ve güncelle
        final currentDefaults = await _getUserDefaults() ?? UserDefaults();
        await _saveUserDefaults(currentDefaults.copyWith(isPro: true));

        // Önceki state'ten değerleri koru
        final previousState = state.valueOrNull;
        return PaywallState(
          isSubscriptionActive: true, // Debug modunda aboneliği aktif olarak zorla
          offerings: previousState?.offerings,
          customerInfo: previousState?.customerInfo,
        );
      }

      try {
        final customerInfo = await Purchases.getCustomerInfo();
        final offerings = await Purchases.getOfferings();

        // Abonelik durumunu kontrol et
        final isActive = customerInfo.entitlements.active.isNotEmpty;

        // Mevcut UserDefaults'ı al ve güncelle
        final currentDefaults = await _getUserDefaults() ?? UserDefaults();
        await _saveUserDefaults(currentDefaults.copyWith(isPro: isActive));

        return PaywallState(
          isSubscriptionActive: isActive,
          customerInfo: customerInfo,
          offerings: offerings,
        );
      } catch (e) {
        LogHelper.shared.debugPrint('Error checking subscription status: $e');

        // Hata durumunda UserDefaults'dan pro durumunu kontrol et
        final userDefaults = await _getUserDefaults();

        // Önceki state'ten değerleri koru
        final previousState = state.valueOrNull;
        return PaywallState(
          isSubscriptionActive: userDefaults?.isPro ?? false,
          offerings: previousState?.offerings,
          customerInfo: previousState?.customerInfo,
        );
      }
    });
  }

  /// Attempts to purchase a package
  Future<void> purchasePackage(Package package, {bool isFromOnboarding = false}) async {
    // Mevcut state'i güvenli bir şekilde al
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // State'i güncelle
    state = AsyncValue.data(currentState.copyWith(isPurchasing: true));

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      final isActive = customerInfo.entitlements.active.isNotEmpty;

      // Mevcut UserDefaults'ı al ve güncelle
      final currentDefaults = await _getUserDefaults() ?? UserDefaults();
      await _saveUserDefaults(currentDefaults.copyWith(isPro: isActive));

      // Önce state'i güncelle
      state = AsyncValue.data(
        currentState.copyWith(
          isPurchasing: false,
          isPurchaseCompleted: true,
          customerInfo: customerInfo,
          isSubscriptionActive: isActive,
        ),
      );

      // Sonra navigator işlemlerini yap
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isFromOnboarding) {
          navigator.navigateAndClear(path: KRoute.homePage);
        } else {
          navigator.pop();
        }
        AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_purchaseSuccessful.tr());
      });
    } on PlatformException catch (e) {
      LogHelper.shared.debugPrint('Platform exception during purchase: ${e.message}');
      // Güncel state'i tekrar kontrol et
      final updatedState = state.valueOrNull;
      if (updatedState != null) {
        state = AsyncValue.data(
          updatedState.copyWith(
            isPurchasing: false,
          ),
        );
      }
      AppFlushbar.shared.errorFlushbar(RevenueCatHelper.getMessageFromException(e));
    } catch (e) {
      // Diğer tüm hataları genel olarak işle
      LogHelper.shared.debugPrint('Unexpected error during purchase: $e');
      // Güncel state'i tekrar kontrol et
      final updatedState = state.valueOrNull;
      if (updatedState != null) {
        state = AsyncValue.data(
          updatedState.copyWith(
            isPurchasing: false,
          ),
        );
      }
      AppFlushbar.shared.errorFlushbar("An unexpected error occurred during purchase");
    }
  }

  /// Attempts to restore previous purchases
  Future<void> restorePurchases({bool isFromOnboarding = false}) async {
    // Mevcut state'i güvenli bir şekilde al
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // State'i güncelle
    state = AsyncValue.data(currentState.copyWith(isRestoring: true));

    try {
      final customerInfo = await Purchases.restorePurchases();
      final isActive = customerInfo.entitlements.active.isNotEmpty;

      // Mevcut UserDefaults'ı al ve güncelle
      final currentDefaults = await _getUserDefaults() ?? UserDefaults();
      await _saveUserDefaults(currentDefaults.copyWith(isPro: isActive));

      // Önce state'i güncelle
      state = AsyncValue.data(
        currentState.copyWith(
          isRestoring: false,
          isRestoreSuccess: true,
          customerInfo: customerInfo,
          isSubscriptionActive: isActive,
        ),
      );

      // Sonra navigator işlemlerini yap
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isFromOnboarding && isActive) {
          navigator.navigateAndClear(path: KRoute.homePage);
        } else {
          navigator.pop();
        }
        AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_restoreSuccessful.tr());
      });
    } on PlatformException catch (e) {
      LogHelper.shared.debugPrint('Platform exception during restore: ${e.message}');
      // Güncel state'i tekrar kontrol et
      final updatedState = state.valueOrNull;
      if (updatedState != null) {
        state = AsyncValue.data(
          updatedState.copyWith(
            isRestoring: false,
            isRestoreSuccess: false,
          ),
        );
      }
      AppFlushbar.shared.errorFlushbar(RevenueCatHelper.getMessageFromException(e));
    } catch (e) {
      // Diğer tüm hataları genel olarak işle
      LogHelper.shared.debugPrint('Unexpected error during restore: $e');
      // Güncel state'i tekrar kontrol et
      final updatedState = state.valueOrNull;
      if (updatedState != null) {
        state = AsyncValue.data(
          updatedState.copyWith(
            isRestoring: false,
            isRestoreSuccess: false,
          ),
        );
      }
      AppFlushbar.shared.errorFlushbar("An unexpected error occurred during restore");
    }
  }

  /// Gets the current active package if any
  Package? getActivePackage() {
    final offerings = state.valueOrNull?.offerings;
    if (offerings == null) return null;

    // Try to get current subscription package
    final currentPackage = offerings.current?.monthly ?? offerings.current?.annual;
    return currentPackage;
  }

  /// Copies the customer ID to clipboard and shows a success message
  Future<void> copyCustomerId() async {
    try {
      final customerInfo = state.valueOrNull?.customerInfo;
      if (customerInfo?.originalAppUserId != null) {
        await Clipboard.setData(ClipboardData(text: customerInfo!.originalAppUserId));
        AppFlushbar.shared.successFlushbar(
          "Your customer ID copied successfully\nID:${customerInfo.originalAppUserId}",
        );
        LogHelper.shared.debugPrint('Customer ID copied to clipboard: ${customerInfo.originalAppUserId}');
      } else {
        LogHelper.shared.debugPrint('Cannot copy customer ID: Customer info or ID is null');
        AppFlushbar.shared.warningFlushbar("Customer ID is not available");
      }
    } catch (e) {
      LogHelper.shared.debugPrint('Error copying customer ID: $e');
      AppFlushbar.shared.errorFlushbar("Failed to copy customer ID");
    }
  }
}
