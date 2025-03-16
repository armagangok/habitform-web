import 'package:habitrise/core/core.dart';

enum CloseButtonPosition { left, right, none }

class SheetHeader extends StatelessWidget implements ObstructingPreferredSizeWidget {
  const SheetHeader({
    super.key,
    this.onClose,
    this.title,
    this.closeButtonPosition = CloseButtonPosition.right,
    this.leading,
    this.trailing,
    this.middle,
  });

  final Function()? onClose;

  final String? title;
  final CloseButtonPosition closeButtonPosition;
  final Widget? leading;
  final Widget? trailing;
  final Widget? middle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CupertinoNavigationBar(
      backgroundColor: context.cupertinoTheme.barBackgroundColor,
      border: Border(
        bottom: BorderSide(
          color: theme.dividerColor.withValues(alpha: .3),
          width: 0.5,
        ),
      ),
      transitionBetweenRoutes: false,
      leading: leading ??
          Align(
            widthFactor: 1,
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 28,
              width: 28,
              child: closeButtonPosition == CloseButtonPosition.left ? _closeButton() : leading,
            ),
          ),
      middle: middle ??
          Text(
            title ?? '',
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
      trailing: trailing ??
          Align(
            widthFactor: 1,
            child: closeButtonPosition == CloseButtonPosition.right ? _closeButton() : trailing,
          ),
    );
  }

  Widget _closeButton() {
    return Builder(builder: (context) {
      return Align(
        widthFactor: 1,
        child: CustomButton(
          onPressed: () {
            onClose?.call();
            navigator.pop();
          },
          child: SizedBox(
            width: 28,
            height: 28,
            child: CupertinoButton.filled(
              disabledColor: context.theme.dividerColor.withValues(alpha: .25),
              borderRadius: BorderRadius.circular(90),
              padding: EdgeInsets.zero,
              onPressed: null,
              child: FittedBox(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(360),
                  ),
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      CupertinoIcons.xmark,
                      color: context.primary.withValues(alpha: .9),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}
