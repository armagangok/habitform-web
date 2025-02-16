part of 'paywall_bloc.dart';

@immutable
abstract class PaywallState {
  const PaywallState();
}

class PaywallInitial extends PaywallState {
  const PaywallInitial();
}

class PaywallLoading extends PaywallState {
  const PaywallLoading();
}

class PaywallError extends PaywallState {
  final String message;
  const PaywallError(this.message);

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaywallError && runtimeType == other.runtimeType && message == other.message;

  @override
  int get hashCode => message.hashCode;
}

enum PurchaseStatus {
  initial,
  inProgress,
  completed,
  failed,
}

class PaywallResult extends PaywallState {
  final Offerings? offerings;
  final CustomerInfo? customerInfo;
  final bool isSubscriptionActive;
  final PurchaseStatus purchaseStatus;
  final bool isRestoring;
  final String? errorMessage;

  const PaywallResult({
    this.offerings,
    this.customerInfo,
    this.isSubscriptionActive = false,
    this.purchaseStatus = PurchaseStatus.initial,
    this.isRestoring = false,
    this.errorMessage,
  });

  bool get isPurchasing => purchaseStatus == PurchaseStatus.inProgress;
  bool get isPurchaseCompleted => purchaseStatus == PurchaseStatus.completed;
  bool get hasPurchaseError => purchaseStatus == PurchaseStatus.failed;
  String? get error => errorMessage;

  PaywallResult copyWith({
    Offerings? offerings,
    CustomerInfo? customerInfo,
    bool? isSubscriptionActive,
    PurchaseStatus? purchaseStatus,
    bool? isRestoring,
    String? errorMessage,
  }) {
    return PaywallResult(
      offerings: offerings ?? this.offerings,
      customerInfo: customerInfo ?? this.customerInfo,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaywallResult && runtimeType == other.runtimeType && offerings == other.offerings && customerInfo == other.customerInfo && isSubscriptionActive == other.isSubscriptionActive && purchaseStatus == other.purchaseStatus && isRestoring == other.isRestoring && errorMessage == other.errorMessage;

  @override
  int get hashCode => offerings.hashCode ^ customerInfo.hashCode ^ isSubscriptionActive.hashCode ^ purchaseStatus.hashCode ^ isRestoring.hashCode ^ errorMessage.hashCode;
}
