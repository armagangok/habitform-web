import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/flushbar_widget.dart';
import '../providers/purchase_provider.dart';

class CopyHelper {
  const CopyHelper._();
  static const shared = CopyHelper._();

  Future<void> copyRCId(BuildContext context) async {
    final customerInfo = ProviderScope.containerOf(context).read(purchaseProvider).value?.customerInfo;

    if (customerInfo?.originalAppUserId != null) {
      AppFlushbar.shared.successFlushbar(
        "Your customer ID copied successfully\nID:${customerInfo?.originalAppUserId}",
      );
    }
  }
}
