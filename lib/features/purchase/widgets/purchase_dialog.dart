import 'package:habitrise/features/purchase/page/paywall_page.dart';

import '../../../core/core.dart';

Future<void> showUnlockProDialog() async {
  final context = navigator.navigatorKey.currentContext;
  if (context == null) return;

  await showCupertinoDialog(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: Text("You need pro to unlock this feature"),
      content: Text("Unlock HabitRise Pro to access this and many other pro features!"),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => PaywallPage(),
            );
          },
          child: Text(
            LocaleKeys.subscription_continue.tr(),
          ),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: Text(
            LocaleKeys.common_cancel.tr(),
          ),
        ),
      ],
    ),
  );
}
