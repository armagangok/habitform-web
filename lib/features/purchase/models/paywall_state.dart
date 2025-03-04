import '../purchase.dart';

class PaywallState {
  final bool isPurchasing;
  final bool isRestoring;
  final bool isPurchaseCompleted;
  final bool isRestoreSuccess;

  final Offerings? offerings;
  final bool isSubscriptionActive;
  final CustomerInfo? customerInfo;

  const PaywallState({
    this.isPurchasing = false,
    this.isRestoring = false,
    this.isPurchaseCompleted = false,
    this.isRestoreSuccess = false,
    this.offerings,
    this.isSubscriptionActive = false,
    this.customerInfo,
  });

  PaywallState copyWith({
    bool? isPurchasing,
    bool? isRestoring,
    bool? isPurchaseCompleted,
    bool? isRestoreSuccess,
    Offerings? offerings,
    bool? isSubscriptionActive,
    CustomerInfo? customerInfo,
  }) {
    return PaywallState(
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      isPurchaseCompleted: isPurchaseCompleted ?? this.isPurchaseCompleted,
      isRestoreSuccess: isRestoreSuccess ?? this.isRestoreSuccess,
      offerings: offerings ?? this.offerings,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      customerInfo: customerInfo ?? this.customerInfo,
    );
  }
}
