import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../providers/purchase_provider.dart';

Future<void> showUnlockProDialog() async {
  final context = navigator.navigatorKey.currentContext;
  if (context == null) return;

  await showAppAlertDialog(
    context: context,
    title: Text(
      LocaleKeys.purchase_dialog_pro_required_title.tr(),
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    content: Text(LocaleKeys.purchase_dialog_pro_required_message.tr()),
    actions: [
      appAlertTextButton(
        context: context,
        label: LocaleKeys.common_later.tr(),
        onPressed: () => Navigator.pop(context),
      ),
      Consumer(
        builder: (ctx, ref, _) {
          return appAlertTextButton(
            context: ctx,
            label: LocaleKeys.subscription_continue.tr(),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(purchaseProvider.notifier).presentPaywall(isFromOnboarding: false);
            },
          );
        },
      ),
    ],
  );
}
