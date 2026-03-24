import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../providers/purchase_provider.dart';

Future<void> showUnlockProDialog() async {
  final context = navigator.navigatorKey.currentContext;
  if (context == null) return;

  await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text(LocaleKeys.purchase_dialog_pro_required_title.tr()),
      content: Text(LocaleKeys.purchase_dialog_pro_required_message.tr()),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            LocaleKeys.common_later.tr(),
            style: const TextStyle(color: CupertinoColors.systemBlue),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            return CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                ref.read(purchaseProvider.notifier).presentPaywall(isFromOnboarding: false);
              },
              child: Text(
                LocaleKeys.subscription_continue.tr(),
                style: const TextStyle(
                  color: CupertinoColors.systemBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}
