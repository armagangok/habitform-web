import 'package:flutter/cupertino.dart';

/// Ensures the subtree spans at least the visible viewport height (useful for web footers and rails).
class WebViewportSizer extends StatelessWidget {
  const WebViewportSizer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height, maxWidth: double.infinity),
      child: child,
    );
  }
}
