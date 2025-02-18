import 'dart:async';

import 'package:flutter/services.dart';

import '/core/core.dart';
import '../../../core/widgets/flushbar_widget.dart';
import '../in_app_purchase/iap.dart';

part 'paywall_event.dart';
part 'paywall_state.dart';

extension PaywallBlocX on PaywallBloc {
  String? get customerId {
    if (state is PaywallResult) {
      return (state as PaywallResult).customerInfo?.originalAppUserId;
    }
    return null;
  }

  Future<bool> copyCustomerId() async {
    final id = customerId;
    if (id != null) {
      await Clipboard.setData(ClipboardData(text: id));
      return true;
    }
    return false;
  }
}

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  PaywallBloc() : super(const PaywallInitial()) {
    on<InitializePaywallEvent>(_onInitialize);
    on<PurchaseProductEvent>(_onPurchaseProduct);
    on<RestorePurchasesEvent>(_onRestorePurchases);
  }

  Future<void> _onInitialize(InitializePaywallEvent event, Emitter<PaywallState> emit) async {
    try {
      emit(const PaywallLoading());

      final customerInfo = await PurchaseService.getCustomerInfo;
      final offerings = await PurchaseService.fetchOffers;
      final isSubscriptionActive = _checkSubscriptionStatus(customerInfo);

      if (offerings.current == null) {
        emit(const PaywallError("Could not load subscription prices"));
        return;
      }

      emit(PaywallResult(
        offerings: offerings,
        customerInfo: customerInfo,
        isSubscriptionActive: isSubscriptionActive,
      ));
    } on PlatformException catch (e) {
      LogHelper.shared.debugPrint('$e\n${e.stacktrace}');
      emit(PaywallError(RevenueCatHelper.getMessageFromException(e)));
    }
  }

  Future<void> _onPurchaseProduct(PurchaseProductEvent event, Emitter<PaywallState> emit) async {
    if (state is! PaywallResult) return;
    final currentState = state as PaywallResult;

    try {
      emit(currentState.copyWith(purchaseStatus: PurchaseStatus.inProgress));

      final customerInfoResult = await PurchaseService.purchasePackage(event.selectedPackage);
      final subscriptionResult = _checkSubscriptionStatus(customerInfoResult);

      emit(PaywallResult(
        offerings: currentState.offerings,
        customerInfo: customerInfoResult,
        isSubscriptionActive: subscriptionResult,
        purchaseStatus: PurchaseStatus.completed,
      ));
    } on PlatformException catch (e) {
      LogHelper.shared.debugPrint('$e\n${e.stacktrace}');
      final error = RevenueCatErrorParser.getErrorFromException(e);
      emit(currentState.copyWith(
        purchaseStatus: PurchaseStatus.failed,
        errorMessage: error != null ? RevenueCatHelper.getMessageFromError(error) : RevenueCatHelper.getMessageFromException(e),
      ));
    }
  }

  Future<void> _onRestorePurchases(RestorePurchasesEvent event, Emitter<PaywallState> emit) async {
    if (state is! PaywallResult) return;
    final currentState = state as PaywallResult;

    try {
      emit(currentState.copyWith(isRestoring: true));

      final response = await PurchaseService.restorePurchases;
      final isSubscriptionActive = _checkSubscriptionStatus(response);

      if (isSubscriptionActive) {
        AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_purchaseRestoredSuccessfuly.tr());
      } else {
        AppFlushbar.shared.warningFlushbar(LocaleKeys.subscription_youDoNotHaveAnyPurchasesToRestore.tr());
      }

      emit(
        PaywallResult(
          offerings: currentState.offerings,
          customerInfo: response,
          isSubscriptionActive: isSubscriptionActive,
          isRestoring: false,
        ),
      );
    } on PlatformException catch (e) {
      LogHelper.shared.debugPrint('$e\n${e.stacktrace}');
      final error = RevenueCatErrorParser.getErrorFromException(e);
      emit(currentState.copyWith(
        isRestoring: false,
        errorMessage: error != null ? RevenueCatHelper.getMessageFromError(error) : RevenueCatHelper.getMessageFromException(e),
      ));
    }
  }

  bool _checkSubscriptionStatus(CustomerInfo? customerInfo) {
    return customerInfo?.entitlements.all[entitlementID]?.isActive == true;
  }
}

