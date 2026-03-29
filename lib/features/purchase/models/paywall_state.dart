class PaywallState {
  final bool isPurchasing;
  final bool isRestoring;
  final bool isPurchaseCompleted;
  final bool isRestoreSuccess;
  final bool isSubscriptionActive;

  const PaywallState({
    this.isPurchasing = false,
    this.isRestoring = false,
    this.isPurchaseCompleted = false,
    this.isRestoreSuccess = false,
    this.isSubscriptionActive = false,
  });

  PaywallState copyWith({
    bool? isPurchasing,
    bool? isRestoring,
    bool? isPurchaseCompleted,
    bool? isRestoreSuccess,
    bool? isSubscriptionActive,
  }) {
    return PaywallState(
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      isPurchaseCompleted: isPurchaseCompleted ?? this.isPurchaseCompleted,
      isRestoreSuccess: isRestoreSuccess ?? this.isRestoreSuccess,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
    );
  }
}
