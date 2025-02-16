import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/paywall_bloc.dart';
import '../../../core/widgets/flushbar_widget.dart';

class CopyHelper {
  const CopyHelper._();
  static const shared = CopyHelper._();

  Future<void> copyRCId(BuildContext context) async {
    final paywallBloc = context.read<PaywallBloc>();
    final success = await paywallBloc.copyCustomerId();

    if (success) {
      AppFlushbar.shared.successFlushbar("Your customer ID copied successfully\nID:${paywallBloc.customerId}");
    }
  }
}
