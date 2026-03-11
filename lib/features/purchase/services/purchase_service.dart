import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../utils/store_config.dart';

class PurchaseService {
  const PurchaseService._();

  static Future<CustomerInfo> get getCustomerInfo async {
    return await Purchases.getCustomerInfo();
  }

  static Future<Offerings> get fetchOffers async {
    return await Purchases.getOfferings();
  }

  static Future<CustomerInfo> get restorePurchases async {
    return await Purchases.restorePurchases();
  }

  static Future<CustomerInfo> purchasePackage(Package package) async {
    return await Purchases.purchasePackage(package);
  }

  static Future<PaywallResult> presentPaywall({Offering? offering}) async {
    return await RevenueCatUI.presentPaywall(offering: offering);
  }

  static Future<PaywallResult> presentPaywallIfNeeded(String entitlementIdentifier, {Offering? offering}) async {
    return await RevenueCatUI.presentPaywallIfNeeded(entitlementIdentifier, offering: offering);
  }

  /// Links RevenueCat to Firebase UID so subscription is shared across devices.
  static Future<void> logIn(String firebaseUid) async {
    await Purchases.logIn(firebaseUid);
  }

  /// Clears RevenueCat user; call when user signs out.
  /// Ignores RevenueCat error when current user is anonymous (no-op in that case).
  static Future<CustomerInfo> logOut() async {
    try {
      return await Purchases.logOut();
    } on PlatformException catch (e) {
      if (e.code == '22' || (e.message?.contains('anonymous') ?? false) || (e.details?.toString().contains('LOGOUT_CALLED_WITH_ANONYMOUS_USER') ?? false)) {
        return await Purchases.getCustomerInfo();
      }
      rethrow;
    }
  }

  static Future<void> configureSDK() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final key = dotenv.env['appleApiKey'];
      if (key != null) {
        StoreConfig(
          store: Store.appStore,
          apiKey: key,
        );
      }
    } else if (Platform.isAndroid) {
      // Run the app passing --dart-define=AMAZON=true
      // const useAmazon = bool.fromEnvironment("amazon");
      final key = dotenv.env['googleApiKey'];
      if (key != null) {
        StoreConfig(
          store: Store.playStore,
          apiKey: key,
        );
      }
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
  }
}
