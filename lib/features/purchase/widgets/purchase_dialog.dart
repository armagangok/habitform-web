import '../../../core/core.dart';
import '../page/paywall_page.dart';

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
          onPressed: () => Navigator.pop(context),
          child: Text(
            LocaleKeys.common_later.tr(),
            style: TextStyle(color: CupertinoColors.systemBlue),
          ),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
            showCupertinoModalBottomSheet(
              enableDrag: false,
              context: context,
              builder: (context) => PaywallPage(),
            );
          },
          child: Text(
            LocaleKeys.subscription_continue.tr(),
            style: TextStyle(
              color: CupertinoColors.systemBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
