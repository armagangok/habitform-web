part of 'paywall_bloc.dart';

@immutable
abstract class PaywallEvent {}

class InitializePaywallEvent extends PaywallEvent {
  InitializePaywallEvent();
}

class PurchaseProductEvent extends PaywallEvent {
  final Package selectedPackage;

  PurchaseProductEvent({required this.selectedPackage});
}

class RestorePurchasesEvent extends PaywallEvent {
  RestorePurchasesEvent();
}
