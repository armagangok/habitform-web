import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Centered, width-capped modal for web instead of full-width Cupertino sheets.
Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  double maxWidth = 640,
  double maxHeightFraction = 0.92,
  bool barrierDismissible = true,
}) {
  final brightness = CupertinoTheme.of(context).brightness ?? Brightness.light;
  final bg = CupertinoTheme.of(context).scaffoldBackgroundColor;
  final radius = BorderRadius.circular(16);

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      final maxH = mq.size.height * maxHeightFraction;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxH),
            child: Material(
              color: bg,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.2),
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: ThemeData(
                  brightness: brightness,
                  useMaterial3: true,
                  canvasColor: bg,
                  scaffoldBackgroundColor: bg,
                ),
                child: Builder(builder: builder),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Alert-style dialog with right-aligned actions (no full-width stacked iOS buttons).
Future<T?> showAppAlertDialog<T>({
  required BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  final brightness = CupertinoTheme.of(context).brightness ?? Brightness.light;
  final cupertino = CupertinoTheme.of(context);

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) {
      return Dialog(
        backgroundColor: cupertino.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Theme(
              data: ThemeData(
                brightness: brightness,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: cupertino.primaryColor,
                  brightness: brightness,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) title,
                  if (title != null && content != null) const SizedBox(height: 12),
                  if (content != null) content,
                  if (actions != null && actions.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8,
                      runSpacing: 8,
                      children: actions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Text button sized to label (does not stretch horizontally).
Widget appAlertTextButton({
  required BuildContext context,
  required String label,
  required VoidCallback onPressed,
  bool isDestructive = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  final color = isDestructive ? scheme.error : scheme.primary;
  return TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      foregroundColor: color,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minimumSize: Size.zero,
    ),
    child: Text(label),
  );
}
