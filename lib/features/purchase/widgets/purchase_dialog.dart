import '../../../core/core.dart';

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
            style: TextStyle(color: CupertinoColors.systemBlue),
          ),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
            navigator.navigateTo(
              path: KRoute.prePaywall,
              data: {'isFromOnboarding': false},
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
