import 'package:flutter/services.dart';

import '../core.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    this.onPressed,
    required this.child,
    this.onLongPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.elevation,
  });

  final Function()? onPressed;
  final Function()? onLongPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 75),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateScale() async {
    if (_isAnimating) return;

    try {
      _isAnimating = true;
      await _controller.forward();
      if (mounted) await _controller.reverse();
    } finally {
      _isAnimating = false;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isAnimating) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isAnimating) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!_isAnimating) {
      _controller.reverse();
    }
  }

  void _handleTap() async {
    if (_isAnimating) return;

    HapticFeedback.mediumImpact();
    await _animateScale();
    if (mounted && widget.onPressed != null) {
      widget.onPressed?.call();
    }
  }

  void _handleLongPress() {
    if (_isAnimating) return;

    widget.onLongPressed?.call();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTap: widget.onPressed != null ? _handleTap : null,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPressed != null ? _handleLongPress : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_controller.value * 0.05),
            child: child,
          );
        },
        child: Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: DefaultTextStyle(
            style: TextStyle(
              color: widget.foregroundColor,
              fontWeight: FontWeight.bold,
            ),
            child: IconTheme(
              data: IconThemeData(
                color: widget.foregroundColor,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
