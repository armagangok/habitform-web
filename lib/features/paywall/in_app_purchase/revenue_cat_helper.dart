import 'package:flutter/services.dart';

import '/core/core.dart';

enum RevenueCatHelper {
  // Purchase related states
  purchaseError,
  purchaseSuccess,
  purchaseCancelled,
  purchaseInProgress,
  purchaseTimeout,
  purchaseInvalidated,

  // Restore related states
  restoreError,
  restoreSuccess,
  restoreInProgress,
  noPurchaseToRestore,

  // Subscription states
  alreadyPurchased,
  subscriptionExpired,
  subscriptionPaused,
  subscriptionResumed,

  // Billing related states
  billingUnavailable,
  billingInvalid,
  priceNotLoaded,

  // Network related states
  networkError,
  serverError,

  // General states
  generalError,
  invalidCredentials,
  notInitialized;

  String get message {
    switch (this) {
      // Purchase messages
      case RevenueCatHelper.purchaseError:
        return LocaleKeys.subscription_purchaseError.tr();
      case RevenueCatHelper.purchaseSuccess:
        return LocaleKeys.subscription_purchaseSuccessful.tr();
      case RevenueCatHelper.purchaseCancelled:
        return LocaleKeys.subscription_purchaseCancelled.tr();
      case RevenueCatHelper.purchaseInProgress:
        return LocaleKeys.subscription_loading.tr();
      case RevenueCatHelper.purchaseTimeout:
        return LocaleKeys.subscription_purchaseTimeout.tr();
      case RevenueCatHelper.purchaseInvalidated:
        return LocaleKeys.subscription_purchaseInvalidated.tr();

      // Restore messages
      case RevenueCatHelper.restoreError:
        return LocaleKeys.subscription_restoreError.tr();
      case RevenueCatHelper.restoreSuccess:
        return LocaleKeys.subscription_purchaseRestoredSuccessfuly.tr();
      case RevenueCatHelper.restoreInProgress:
        return LocaleKeys.subscription_loading.tr();
      case RevenueCatHelper.noPurchaseToRestore:
        return LocaleKeys.subscription_youDoNotHaveAnyPurchasesToRestore.tr();

      // Subscription messages
      case RevenueCatHelper.alreadyPurchased:
        return LocaleKeys.subscription_youAlreadyHaveAnActiveSubscription.tr();
      case RevenueCatHelper.subscriptionExpired:
        return LocaleKeys.subscription_subscriptionExpired.tr();
      case RevenueCatHelper.subscriptionPaused:
        return LocaleKeys.subscription_subscriptionPaused.tr();
      case RevenueCatHelper.subscriptionResumed:
        return LocaleKeys.subscription_subscriptionResumed.tr();

      // Billing messages
      case RevenueCatHelper.billingUnavailable:
        return LocaleKeys.subscription_billingUnavailable.tr();
      case RevenueCatHelper.billingInvalid:
        return LocaleKeys.subscription_billingInvalid.tr();
      case RevenueCatHelper.priceNotLoaded:
        return LocaleKeys.subscription_priceNotLoaded.tr();

      // Network messages
      case RevenueCatHelper.networkError:
        return LocaleKeys.subscription_networkError.tr();
      case RevenueCatHelper.serverError:
        return LocaleKeys.subscription_serverError.tr();

      // General messages
      case RevenueCatHelper.generalError:
        return LocaleKeys.errors_try_again.tr();
      case RevenueCatHelper.invalidCredentials:
        return LocaleKeys.subscription_invalidCredentials.tr();
      case RevenueCatHelper.notInitialized:
        return LocaleKeys.subscription_notInitialized.tr();
    }
  }

  static RevenueCatHelper fromPlatformException(PlatformException exception) {
    final code = exception.code.toLowerCase();
    final details = exception.details?.toString().toLowerCase() ?? '';
    final message = exception.message?.toLowerCase() ?? '';

    // Purchase related errors
    if (code.contains('purchase_error') || message.contains('purchase')) {
      if (message.contains('cancel') || details.contains('cancel')) {
        return RevenueCatHelper.purchaseCancelled;
      }
      if (message.contains('timeout') || details.contains('timeout')) {
        return RevenueCatHelper.purchaseTimeout;
      }
      if (message.contains('invalid') || details.contains('invalid')) {
        return RevenueCatHelper.purchaseInvalidated;
      }
      return RevenueCatHelper.purchaseError;
    }

    // Restore related errors
    if (code.contains('restore') || message.contains('restore')) {
      if (message.contains('no purchases') || details.contains('no purchases')) {
        return RevenueCatHelper.noPurchaseToRestore;
      }
      return RevenueCatHelper.restoreError;
    }

    // Billing related errors
    if (code.contains('billing')) {
      if (message.contains('unavailable') || details.contains('unavailable')) {
        return RevenueCatHelper.billingUnavailable;
      }
      return RevenueCatHelper.billingInvalid;
    }

    // Network related errors
    if (code.contains('network') || message.contains('network') || details.contains('network')) {
      return RevenueCatHelper.networkError;
    }
    if (code.contains('server') || message.contains('server') || details.contains('server')) {
      return RevenueCatHelper.serverError;
    }

    // Subscription related errors
    if (message.contains('already purchased') || details.contains('already purchased')) {
      return RevenueCatHelper.alreadyPurchased;
    }
    if (message.contains('expired') || details.contains('expired')) {
      return RevenueCatHelper.subscriptionExpired;
    }
    if (message.contains('paused') || details.contains('paused')) {
      return RevenueCatHelper.subscriptionPaused;
    }

    // Other errors
    if (code.contains('not_initialized') || message.contains('not initialized')) {
      return RevenueCatHelper.notInitialized;
    }
    if (code.contains('invalid_credentials') || message.contains('invalid credentials')) {
      return RevenueCatHelper.invalidCredentials;
    }

    return RevenueCatHelper.generalError;
  }
}
