// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:habitrise/core/core.dart';

enum CloseButtonPosition { left, right, none }

class SheetHeader extends StatelessWidget implements ObstructingPreferredSizeWidget {
  const SheetHeader({
    super.key,
    this.onClose,
    required this.title,
    this.closeButtonPosition = CloseButtonPosition.right,
    this.leading,
    this.trailing,
  });

  final Function()? onClose;

  final String title;
  final CloseButtonPosition closeButtonPosition;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CupertinoNavigationBar(
      // backgroundColor: Colors.transparent,
      border: Border(
        bottom: BorderSide(
          color: CupertinoColors.separator,
          width: 0.5, // Adjust thickness as needed
        ),
      ),
      transitionBetweenRoutes: false,
      leading: Align(
        widthFactor: 1,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 28,
          width: 28,
          child: closeButtonPosition == CloseButtonPosition.left ? _closeButton(context) : leading,
        ),
      ),
      middle: Text(title),
      trailing: Align(
        widthFactor: 1,
        child: closeButtonPosition == CloseButtonPosition.right ? _closeButton(context) : trailing,
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return Align(
      widthFactor: 1,
      child: SizedBox(
        height: 28,
        width: 28,
        child: CupertinoButton(
          color: context.iconTheme.color?.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(90),
          padding: EdgeInsets.zero,
          onPressed: () {
            onClose?.call();
            navigator.pop();
          },
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
                  color: context.iconTheme.color?.withAlpha(250),
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}
