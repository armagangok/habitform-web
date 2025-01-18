import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/core.dart';
import 'constants.dart';
import 'store_config.dart';

final class PurchaseService {
  const PurchaseService._();

  static Future<Offerings> get fetchOffers async {
    final Offerings offerings = await Purchases.getOfferings();
    return offerings;
  }

  /// Purchase package and return the membership result as `bool`
  static Future<CustomerInfo> purchasePackage(Package packageToPurchase) async {
    final CustomerInfo customerInfo = await Purchases.purchasePackage(packageToPurchase);

    return customerInfo;
  }

  // /// Get customer info and, by using this customer info check wheter user has subcscription and return the value as `bool`
  // static Future<bool> get isMembershipActive async {
  //   final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
  //   final isSubscriptionActive = customerInfo.entitlements.all[entitlementID] != null && customerInfo.entitlements.all[entitlementID]!.isActive;

  //   return isSubscriptionActive;
  // }

  static Future<CustomerInfo> get getCustomerInfo async {
    final CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    return customerInfo;
  }

  static Future<CustomerInfo> get restorePurchases async {
    final CustomerInfo customerInfo = await Purchases.restorePurchases();
    return customerInfo;
  }

  static Future<void> configureSDK() async {
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        StoreConfig(
          store: Store.appStore,
          apiKey: appleApiKey,
        );
      } else if (Platform.isAndroid) {
        // Run the app passing --dart-define=AMAZON=true
        const useAmazon = bool.fromEnvironment("amazon");
        StoreConfig(
          store: useAmazon ? Store.amazon : Store.playStore,
          apiKey: useAmazon ? amazonApiKey : googleApiKey,
        );
      }

      // Enable debug logs before calling `configure`.
      await Purchases.setLogLevel(LogLevel.debug);

      /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK. Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids

    - observerMode is false, so Purchases will automatically handle finishing transactions. Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
      PurchasesConfiguration configuration;
      if (StoreConfig.isForAmazonAppstore()) {
        configuration = AmazonConfiguration(StoreConfig.instance.apiKey)..appUserID = null;
      } else {
        configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)..appUserID = null;
      }
      await Purchases.configure(configuration);
    } catch (e, s) {
      LogHelper.shared.debugPrint('$e');
      LogHelper.shared.debugPrint('$s');
    }
  }
}
