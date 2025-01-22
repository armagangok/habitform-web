import 'package:flutter/services.dart';

import '/core/core.dart';
import '/core/widgets/flushbar_widget.dart';
import '../in_app_purchase/iap.dart';

part 'paywall_event.dart';
part 'paywall_state.dart';

class PaywallBloc extends Bloc<PaywallEvent, PaywallState> {
  PaywallBloc() : super(PaywallInitial()) {
    on<InitializePaywallEvent>(_onInitialize);
    on<PurchaseProductEvent>(_onPurchaseProduct);
    on<RestorePurchasesEvent>(_onRestorePurchases);
  }

  Future<void> _onInitialize(InitializePaywallEvent event, Emitter<PaywallState> emit) async {
    try {
      emit(PaywallLoading());

      final customerInfo = await PurchaseService.getCustomerInfo;
      final offerings = await PurchaseService.fetchOffers;
      final isSubscriptionActive = _checkSubscriptionStatus(customerInfo);

      print(isSubscriptionActive);

      LogHelper.shared.debugPrint('$customerInfo');
      LogHelper.shared.debugPrint('$offerings');
      LogHelper.shared.debugPrint('$isSubscriptionActive');

      emit(PaywallLoaded(
        offerings: offerings,
        customerInfo: customerInfo,
        isSubscriptionActive: isSubscriptionActive,
        isPurchasing: false,
        isRestoring: false,
      ));
    } on PlatformException catch (e, s) {
      LogHelper.shared.debugPrint('$e\n$s');
      emit(PaywallError(message: e.message ?? LocaleKeys.errors_try_again.tr()));
    }
  }

  Future<void> _onPurchaseProduct(PurchaseProductEvent event, Emitter<PaywallState> emit) async {
    if (state is! PaywallLoaded) return;
    final currentState = state as PaywallLoaded;

    try {
      emit(currentState.copyWith(isPurchasing: true));

      final customerInfoResult = await PurchaseService.purchasePackage(event.selectedPackage);
      final subscriptionResult = _checkSubscriptionStatus(customerInfoResult);

      if (!subscriptionResult) {
        AppFlushbar.shared.warningFlushbar(LocaleKeys.subscription_anIssueOccuredWhilePurchasing.tr());
      }

      emit(PaywallLoaded(
        offerings: currentState.offerings,
        customerInfo: customerInfoResult,
        isSubscriptionActive: subscriptionResult,
        isPurchasing: false,
        isRestoring: false,
      ));

      navigator.pop();
    } on PlatformException catch (e) {
      AppFlushbar.shared.warningFlushbar(e.message ?? LocaleKeys.errors_try_again.tr());
      LogHelper.shared.debugPrint('$e\n${e.stacktrace}');
      emit(currentState.copyWith(isPurchasing: false));
    }
  }

  Future<void> _onRestorePurchases(RestorePurchasesEvent event, Emitter<PaywallState> emit) async {
    if (state is! PaywallLoaded) return;
    final currentState = state as PaywallLoaded;

    if (currentState.isSubscriptionActive) {
      AppFlushbar.shared.warningFlushbar(LocaleKeys.subscription_youAlreadyHaveAnActiveSubscription.tr());
      return;
    }

    try {
      emit(currentState.copyWith(isRestoring: true));

      final response = await PurchaseService.restorePurchases;
      final isSubscriptionActive = _checkSubscriptionStatus(response);

      emit(PaywallLoaded(
        offerings: currentState.offerings,
        customerInfo: response,
        isSubscriptionActive: isSubscriptionActive,
        isPurchasing: false,
        isRestoring: false,
      ));

      if (isSubscriptionActive) {
        AppFlushbar.shared.successFlushbar(LocaleKeys.subscription_purchaseRestoredSuccessfuly.tr());
      } else {
        AppFlushbar.shared.warningFlushbar(LocaleKeys.subscription_youDoNotHaveAnyPurchasesToRestore.tr());
      }
    } on PlatformException catch (e, s) {
      AppFlushbar.shared.errorFlushbar(e.message ?? LocaleKeys.errors_try_again.tr());
      LogHelper.shared.debugPrint('$e\n$s');

      final updatedState = currentState.copyWith(isRestoring: false);
      emit(updatedState);
    }
  }

  bool _checkSubscriptionStatus(CustomerInfo? customerInfo) {
    return customerInfo?.entitlements.all[entitlementID] != null && customerInfo?.entitlements.all[entitlementID]?.isActive == true;
  }
}
