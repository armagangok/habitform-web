// import 'dart:io';

// import 'package:flutter/services.dart';

// import '/core/core.dart';
// import '../../../core/constants/debug_constants.dart';
// import '../../../core/widgets/flushbar_widget.dart';
// import '../in_app_purchase/iap.dart';
// import '../widgets/paywall_widget.dart';

// final purchaseProvider = ChangeNotifierProvider<PurchaseNotifier>((ref) => PurchaseNotifier());

// class PurchaseNotifier extends ChangeNotifier {
//   bool isPurchasing = false;
//   bool isRestoring = false;

//   Offerings? offerings;

//   bool isSubscriptionActive = false;

//   CustomerInfo? customerInfo;

//   Future<void> initPurchaseState() async {
//     try {
//       await setPurchaseState(true);
//       final customerInfo = await PurchaseService.getCustomerInfo;
//       offerings = await PurchaseService.fetchOffers;
//       this.customerInfo = customerInfo;
//       isSubscriptionActive = checkSubscriptionStatus(customerInfo);
//     } on PlatformException catch (e, s) {
//       LogHelper.shared.debugPrint('$e}\n$s');
//     }

//     if (KDebug.purchaseDebugMode) isSubscriptionActive = true;
//     setPurchaseState(false);
//   }

//   Future<void> setPurchaseState(bool loading) async {
//     isPurchasing = loading;
//     notifyListeners();
//   }

//   Future<void> purchaseProduct(Package selectedPackage) async {
//     isPurchasing = true;
//     notifyListeners();

//     try {
//       final customerInfoResult = await PurchaseService.purchasePackage(selectedPackage);

//       final subscriptionResult = checkSubscriptionStatus(customerInfoResult);

//       customerInfo = customerInfoResult;
//       isSubscriptionActive = subscriptionResult;

//       if (subscriptionResult == false) {
//         AppFlushbar.shared.warningFlushbar("LocaleKeys.anIssueOccuredWhilePurchasing.tr()");
//       }

//       navigator.pop();
//     } on PlatformException catch (e) {
//       AppFlushbar.shared.warningFlushbar(e.message ?? "LocaleKeys.anIssueOccuredWhilePurchasing.tr()");
//       LogHelper.shared.debugPrint('$e\n${e.stacktrace}');
//     }

//     isPurchasing = false;
//     notifyListeners();
//   }

//   bool checkSubscriptionStatus(CustomerInfo? customerInfo) {
//     final isActive = customerInfo?.entitlements.all[entitlementID] != null && customerInfo?.entitlements.all[entitlementID]?.isActive == true;
//     return isActive;
//   }

//   Future<void> get restorePurchases async {
//     if (isSubscriptionActive) {
//       AppFlushbar.shared.warningFlushbar("LocaleKeys.youAlreadyHaveAnActiveSubscription.tr()");
//       return;
//     }

//     isRestoring = true;
//     notifyListeners();

//     try {
//       final response = await PurchaseService.restorePurchases;

//       isSubscriptionActive = response.entitlements.all[entitlementID] != null && response.entitlements.all[entitlementID]?.isActive == true;
//       notifyListeners();

//       if (isSubscriptionActive) {
//         AppFlushbar.shared.successFlushbar("LocaleKeys.purchaseRestoredSuccessfuly.tr()");
//       } else {
//         AppFlushbar.shared.warningFlushbar("LocaleKeys.youDoNotHaveAnyPurchasesToRestore.tr()");
//       }
//     } on PlatformException catch (e, s) {
//       AppFlushbar.shared.errorFlushbar(e.message ?? "LocaleKeys.pleaseTryAgainLater.tr()");
//       LogHelper.shared.debugPrint('$e\n$s');
//     }
//     isRestoring = false;
//     notifyListeners();
//   }

//   Future<void> showPaywallOnLaunch(BuildContext context) async {
//     if (!isSubscriptionActive) {
//       if (offerings != null) {
//         await Future.delayed(Duration(milliseconds: 700));

//         showCupertinoModalBottomSheet(
//           expand: true,
//           elevation: 0,
//           enableDrag: false,
//           context: context,
//           builder: (contextFromSheet) => PaywallWidget(),
//         );
//       } else {
//         AppFlushbar.shared.warningFlushbar("LocaleKeys.pleaseMakeSureThat.tr()");
//       }
//     }
//   }
// }

// class ShowDialogToDismiss extends StatelessWidget {
//   final String content;
//   final String title;
//   final String buttonText;

//   const ShowDialogToDismiss({
//     super.key,
//     required this.title,
//     required this.buttonText,
//     required this.content,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (!Platform.isIOS) {
//       return AlertDialog(
//         title: Text(
//           title,
//         ),
//         content: Text(
//           content,
//         ),
//         actions: <Widget>[
//           CupertinoButton(
//             color: context.primary,
//             child: Text(
//               buttonText,
//               style: TextStyle(color: Colors.white),
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     } else {
//       return CupertinoAlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: <Widget>[
//           CupertinoDialogAction(
//             isDefaultAction: true,
//             child: Text(
//               buttonText[0].toUpperCase() + buttonText.substring(1).toLowerCase(),
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     }
//   }
// }
