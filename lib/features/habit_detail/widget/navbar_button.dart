import '/core/core.dart';

class NavBarButton extends StatelessWidget {
  const NavBarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            color: color,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            sizeStyle: CupertinoButtonSize.small,
            onPressed: onPressed,
            child: Icon(
              icon,
              size: 20,
              color: color?.colorRegardingToBrightness,
            ),
          ),
          const SizedBox(height: 2.5),
          Text(
            label,
            style: context.bodySmall,
          ),
        ],
      ),
    );
  }
}
