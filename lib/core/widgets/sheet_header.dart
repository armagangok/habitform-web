import '../core.dart';

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
    return CupertinoNavigationBar(
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
            style: const TextStyle(
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
    return Builder(
      builder: (context) {
        return Align(
          widthFactor: 1,
          child: FittedBox(
            child: SizedBox(
              width: 40,
              height: 40,
              child: CircularActionButton(
                onPressed: () {
                  onClose?.call();
                  navigator.pop();
                },
                icon: CupertinoIcons.xmark,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}
