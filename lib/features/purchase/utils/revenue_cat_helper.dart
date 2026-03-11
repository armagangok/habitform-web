import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '/core/core.dart';

class RevenueCatHelper {
  const RevenueCatHelper._();

  static String get purchaseSuccessMessage => LocaleKeys.subscription_purchaseSuccessful.tr();

  static String get loadingMessage => LocaleKeys.subscription_loading.tr();
  static String get alreadyPurchasedMessage => LocaleKeys.subscription_youAlreadyHaveAnActiveSubscription.tr();

  static String getMessageFromError(PurchasesError error) {
    switch (error.code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return LocaleKeys.subscription_purchaseCancelled.tr();
      case PurchasesErrorCode.purchaseNotAllowedError:
        return LocaleKeys.subscription_purchaseNotAllowed.tr();
      case PurchasesErrorCode.purchaseInvalidError:
        return LocaleKeys.subscription_purchaseInvalidated.tr();
      case PurchasesErrorCode.networkError:
        return LocaleKeys.subscription_networkError.tr();
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return alreadyPurchasedMessage;
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return LocaleKeys.subscription_receiptAlreadyInUse.tr();
      case PurchasesErrorCode.invalidCredentialsError:
        return LocaleKeys.subscription_invalidCredentials.tr();
      case PurchasesErrorCode.paymentPendingError:
        return LocaleKeys.subscription_paymentPending.tr();
      case PurchasesErrorCode.insufficientPermissionsError:
        return LocaleKeys.subscription_insufficientPermissions.tr();
      case PurchasesErrorCode.invalidReceiptError:
        return LocaleKeys.subscription_invalidReceipt.tr();
      case PurchasesErrorCode.storeProblemError:
        return LocaleKeys.subscription_storeProblem.tr();
      case PurchasesErrorCode.unsupportedError:
        return LocaleKeys.subscription_unsupportedFeature.tr();
      case PurchasesErrorCode.invalidAppUserIdError:
        return LocaleKeys.subscription_invalidUserID.tr();
      case PurchasesErrorCode.operationAlreadyInProgressError:
        return LocaleKeys.subscription_operationInProgress.tr();
      case PurchasesErrorCode.unknownError:
        return LocaleKeys.subscription_unknownError.tr();
      case PurchasesErrorCode.invalidAppleSubscriptionKeyError:
        return LocaleKeys.subscription_invalidAppleKey.tr();
      case PurchasesErrorCode.ineligibleError:
        return LocaleKeys.subscription_ineligible.tr();
      case PurchasesErrorCode.configurationError:
        return LocaleKeys.subscription_configurationError.tr();
      case PurchasesErrorCode.unexpectedBackendResponseError:
        return LocaleKeys.subscription_unexpectedResponse.tr();
      case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
        return LocaleKeys.subscription_accountAlreadyUsed.tr();
      default:
        _logErrorDetails(error);
        return LocaleKeys.errors_try_again.tr();
    }
  }

  static void _logErrorDetails(PurchasesError error, [StackTrace? stackTrace]) {
    debugPrint('''
    RevenueCat Error:
    Code: ${error.code}
    Message: ${error.message}
    Underlying Error: ${error.underlyingErrorMessage}
    Stack Trace: ${stackTrace ?? 'N/A'}
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
  static final Map<String, PurchasesErrorCode> _errorCodeMap = {
    // Billing Issues
    'PURCHASE_CANCELLED': PurchasesErrorCode.purchaseCancelledError,
    'PURCHASE_NOT_ALLOWED': PurchasesErrorCode.purchaseNotAllowedError,
    'PURCHASE_INVALID': PurchasesErrorCode.purchaseInvalidError,
    'PRODUCT_ALREADY_PURCHASED': PurchasesErrorCode.productAlreadyPurchasedError,
    'PAYMENT_PENDING': PurchasesErrorCode.paymentPendingError,
    'BILLING_UNAVAILABLE': PurchasesErrorCode.insufficientPermissionsError,

    // Store & Network Issues
    'STORE_PROBLEM': PurchasesErrorCode.storeProblemError,
    'NETWORK_ERROR': PurchasesErrorCode.networkError,
    'INVALID_RECEIPT': PurchasesErrorCode.invalidReceiptError,
    'RECEIPT_ALREADY_IN_USE': PurchasesErrorCode.receiptAlreadyInUseError,
    'RECEIPT_IN_USE_BY_OTHER_SUBSCRIBER': PurchasesErrorCode.receiptInUseByOtherSubscriberError,

    // Configuration & Setup Issues
    'INVALID_CREDENTIALS': PurchasesErrorCode.invalidCredentialsError,
    'CONFIGURATION': PurchasesErrorCode.configurationError,
    'UNSUPPORTED': PurchasesErrorCode.unsupportedError,
    'INVALID_APP_USER_ID': PurchasesErrorCode.invalidAppUserIdError,
    'INVALID_APPLE_SUBSCRIPTION_KEY': PurchasesErrorCode.invalidAppleSubscriptionKeyError,

    // Operation Issues
    'OPERATION_ALREADY_IN_PROGRESS': PurchasesErrorCode.operationAlreadyInProgressError,
    'UNKNOWN_ERROR': PurchasesErrorCode.unknownError,
    'INELIGIBLE': PurchasesErrorCode.ineligibleError,
    'INSUFFICIENT_PERMISSIONS': PurchasesErrorCode.insufficientPermissionsError,

    // Backend Issues
    'UNKNOWN_BACKEND_ERROR': PurchasesErrorCode.unknownBackendError,
    'UNEXPECTED_BACKEND_RESPONSE': PurchasesErrorCode.unexpectedBackendResponseError,

    // Additional Error Codes
    'CUSTOMER_INFO_ERROR': PurchasesErrorCode.unknownError,
    'INVALID_PROMOTIONAL_OFFER': PurchasesErrorCode.purchaseInvalidError,
    'MISSING_PROMOTIONAL_OFFER': PurchasesErrorCode.purchaseInvalidError,
    'BEGIN_BILLING_ERROR': PurchasesErrorCode.storeProblemError,
    'PURCHASE_DUPLICATE': PurchasesErrorCode.productAlreadyPurchasedError,
    'INVALID_PURCHASE_TOKEN': PurchasesErrorCode.purchaseInvalidError,
    'INVALID_SUBSCRIBER_ATTRIBUTES': PurchasesErrorCode.invalidAppUserIdError,
    'APP_STORE_SYNC_IN_PROGRESS': PurchasesErrorCode.operationAlreadyInProgressError,
    'PLAY_STORE_SYNC_IN_PROGRESS': PurchasesErrorCode.operationAlreadyInProgressError,
    'RECEIPT_FAILED_TO_PARSE': PurchasesErrorCode.invalidReceiptError,
    'OFFERING_ID_NOT_FOUND': PurchasesErrorCode.configurationError,
    'PRODUCT_ID_NOT_FOUND': PurchasesErrorCode.configurationError,
    'ENTITLEMENT_NOT_FOUND': PurchasesErrorCode.configurationError,
    'CACHE_POLICY_NOT_SUPPORTED': PurchasesErrorCode.unsupportedError,
    'SIGNATURE_VERIFICATION_FAILED': PurchasesErrorCode.invalidReceiptError,
  };

  static PurchasesErrorCode getErrorCode(String code) {
    final normalizedCode = code.split('.').last.toUpperCase();
    return _errorCodeMap[normalizedCode] ?? _tryFallbackErrorCode(normalizedCode);
  }

  static PurchasesErrorCode _tryFallbackErrorCode(String code) {
    try {
      return PurchasesErrorCode.values.firstWhere(
        (e) => e.name.toUpperCase() == code,
        orElse: () => PurchasesErrorCode.unknownError,
      );
    } catch (e) {
      return PurchasesErrorCode.unknownError;
    }
  }

  static PurchasesError? getErrorFromException(PlatformException exception) {
    try {
      if (exception.details is Map<Object?, Object?>) {
        final rawDetails = exception.details as Map<Object?, Object?>;
        final details = Map<String, dynamic>.from(rawDetails.map((key, value) => MapEntry(key.toString(), value)));

        final code = details['readableErrorCode']?.toString() ?? details['readable_error_code']?.toString() ?? _extractErrorCode(details, exception);

        final errorCode = getErrorCode(code);
        final underlyingMessage = details['underlyingErrorMessage']?.toString() ?? details['message']?.toString() ?? exception.message ?? '';

        return PurchasesError(
          errorCode,
          exception.message ?? '',
          exception.details.toString(),
          underlyingMessage,
        );
      }
    } catch (e, stackTrace) {
      RevenueCatHelper._logErrorDetails(
        PurchasesError(PurchasesErrorCode.unknownError, e.toString(), '', ''),
        stackTrace,
      );
    }
    return null;
  }

  static String _extractErrorCode(Map<String, dynamic> details, PlatformException exception) {
    const possibleCodeKeys = ['readableErrorCode', 'readable_error_code', 'errorCode', 'error_code', 'code'];

    for (final key in possibleCodeKeys) {
      if (details.containsKey(key)) {
        return details[key]?.toString() ?? '';
      }
    }
    return exception.code;
  }
}
