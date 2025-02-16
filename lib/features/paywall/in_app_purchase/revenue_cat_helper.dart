import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart';

class RevenueCatHelper {
  static String get purchaseSuccessMessage => LocaleKeys.subscription_purchaseSuccessful.tr();
  static String get restoreSuccessMessage => LocaleKeys.subscription_purchaseRestoredSuccessfuly.tr();
  static String get loadingMessage => LocaleKeys.subscription_loading.tr();
  static String get alreadyPurchasedMessage => LocaleKeys.subscription_youAlreadyHaveAnActiveSubscription.tr();

  static String getMessageFromError(PurchasesError error) {
    switch (error.code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return LocaleKeys.subscription_purchaseCancelled.tr();
      case PurchasesErrorCode.purchaseNotAllowedError:
        return LocaleKeys.subscription_purchaseError.tr();
      case PurchasesErrorCode.purchaseInvalidError:
        return LocaleKeys.subscription_purchaseInvalidated.tr();
      case PurchasesErrorCode.networkError:
        return LocaleKeys.subscription_networkError.tr();
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return alreadyPurchasedMessage;
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return LocaleKeys.subscription_restoreError.tr();
      case PurchasesErrorCode.invalidCredentialsError:
        return LocaleKeys.subscription_invalidCredentials.tr();
      case PurchasesErrorCode.paymentPendingError:
        return LocaleKeys.subscription_purchaseTimeout.tr();
      case PurchasesErrorCode.insufficientPermissionsError:
        return LocaleKeys.subscription_billingUnavailable.tr();
      default:
        _logErrorDetails(error);
        return LocaleKeys.errors_try_again.tr();
    }
  }

  static void _logErrorDetails(PurchasesError error) {
    debugPrint('''
    RevenueCat Error:
    Code: ${error.code}
    Message: ${error.message}
    Underlying Error: ${error.underlyingErrorMessage}
    ''');
  }

  static String getMessageFromException(PlatformException exception) {
    final error = RevenueCatErrorParser.getErrorFromException(exception);
    if (error != null) {
      return getMessageFromError(error);
    }
    return LocaleKeys.errors_try_again.tr();
  }
}

class RevenueCatErrorParser {
  static PurchasesErrorCode getErrorCode(String code) {
    try {
      return PurchasesErrorCode.values.firstWhere(
        (e) => e.toString().split('.').last == code,
        orElse: () => PurchasesErrorCode.unknownError,
      );
    } catch (e) {
      return PurchasesErrorCode.unknownError;
    }
  }

  static PurchasesError? getErrorFromException(PlatformException exception) {
    try {
      if (exception.details is Map) {
        final Map<String, dynamic> details = exception.details as Map<String, dynamic>;
        final code = details['code'] as String?;
        if (code != null) {
          final errorCode = getErrorCode(code);
          return PurchasesError(errorCode, exception.message ?? '', exception.details, details['underlyingErrorMessage'] ?? '');
        }
      }
    } catch (e) {
      debugPrint('Error parsing exception: $e');
    }
    return null;
  }
}
