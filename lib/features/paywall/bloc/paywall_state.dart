part of 'paywall_bloc.dart';

@immutable
abstract class PaywallState {}

class PaywallInitial extends PaywallState {}

class PaywallLoading extends PaywallState {}

class PaywallLoaded extends PaywallState {
  final Offerings? offerings;
  final CustomerInfo? customerInfo;
  final bool isSubscriptionActive;
  final bool isPurchasing;
  final bool isRestoring;

  PaywallLoaded({
    required this.offerings,
    required this.customerInfo,
    required this.isSubscriptionActive,
    required this.isPurchasing,
    required this.isRestoring,
  });

  PaywallLoaded copyWith({
    Offerings? offerings,
    CustomerInfo? customerInfo,
    bool? isSubscriptionActive,
    bool? isPurchasing,
    bool? isRestoring,
  }) {
    return PaywallLoaded(
      offerings: offerings ?? this.offerings,
      customerInfo: customerInfo ?? this.customerInfo,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
    );
  }
}

class PaywallError extends PaywallState {
  final String message;

  PaywallError({required this.message});
}
