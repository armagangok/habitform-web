part of 'paywall_bloc.dart';

@immutable
abstract class PaywallEvent {
  const PaywallEvent();
}

class InitializePaywallEvent extends PaywallEvent {
  const InitializePaywallEvent();
}

class PurchaseProductEvent extends PaywallEvent {
  final Package selectedPackage;
  final bool isFromOnboarding;

  const PurchaseProductEvent({
    required this.selectedPackage,
    this.isFromOnboarding = false,
  });

  @override
  bool operator ==(Object other) => identical(this, other) || other is PurchaseProductEvent && runtimeType == other.runtimeType && selectedPackage == other.selectedPackage && isFromOnboarding == other.isFromOnboarding;

  @override
  int get hashCode => selectedPackage.hashCode ^ isFromOnboarding.hashCode;
}

class RestorePurchasesEvent extends PaywallEvent {
  const RestorePurchasesEvent();
}



class PurchaseProductFromOnboardingEvent extends PaywallEvent {
  final Package selectedPackage;

  const PurchaseProductFromOnboardingEvent({required this.selectedPackage});
}
