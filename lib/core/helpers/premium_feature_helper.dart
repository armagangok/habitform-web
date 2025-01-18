import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../features/paywall/bloc/paywall_bloc.dart';
import '../../features/paywall/widgets/paywall_widget.dart';
import '../widgets/flushbar_widget.dart';

class PremiumFeatureHelper {
  static bool checkAccess(BuildContext context, {bool showPaywall = true}) {
    final paywallState = context.read<PaywallBloc>().state;
    if (paywallState is! PaywallLoaded) {
      return false;
    }

    if (!paywallState.isSubscriptionActive) {
      if (showPaywall) {
        showCupertinoModalBottomSheet(
          expand: true,
          elevation: 0,
          enableDrag: false,
          context: context,
          builder: (contextFromSheet) => PaywallWidget(),
        );
      }
      return false;
    }

    return true;
  }

  static Future<bool> requirePremium(BuildContext context, {String? message}) async {
    final hasAccess = checkAccess(context, showPaywall: false);
    if (!hasAccess) {
      if (message != null) {
        AppFlushbar.shared.warningFlushbar(message);
      }

      showCupertinoModalBottomSheet(
        expand: true,
        elevation: 0,
        enableDrag: false,
        context: context,
        builder: (contextFromSheet) => PaywallWidget(),
      );
      return false;
    }
    return true;
  }
}
