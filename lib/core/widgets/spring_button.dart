//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// © Cosmos Software | Ali Yigit Bireroglu                                                                                                           /
// All material used in the making of this code, project, program, application, software et cetera (the "Intellectual Property")                     /
// belongs completely and solely to Ali Yigit Bireroglu. This includes but is not limited to the source code, the multimedia and                     /
// other asset files. If you were granted this Intellectual Property for personal use, you are obligated to include this copyright                   /
// text at all times.                                                                                                                                /
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
library;

import 'package:flutter/material.dart';

typedef SpringButtonState = _SpringButtonState;

class GestureCallbackSet {
  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureTapCancelCallback? onTapCancel;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapCancelCallback? onSecondaryTapCancel;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
  final GestureLongPressUpCallback? onLongPressUp;
  final GestureLongPressEndCallback? onLongPressEnd;
  final GestureDragDownCallback? onVerticalDragDown;
  final GestureDragStartCallback? onVerticalDragStart;
  final GestureDragUpdateCallback? onVerticalDragUpdate;
  final GestureDragEndCallback? onVerticalDragEnd;
  final GestureDragCancelCallback? onVerticalDragCancel;
  final GestureDragDownCallback? onHorizontalDragDown;
  final GestureDragStartCallback? onHorizontalDragStart;
  final GestureDragUpdateCallback? onHorizontalDragUpdate;
  final GestureDragEndCallback? onHorizontalDragEnd;
  final GestureDragCancelCallback? onHorizontalDragCancel;
  final GestureDragDownCallback? onPanDown;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
  final GestureDragCancelCallback? onPanCancel;
  final GestureScaleStartCallback? onScaleStart;
  final GestureScaleUpdateCallback? onScaleUpdate;
  final GestureScaleEndCallback? onScaleEnd;
  final GestureForcePressStartCallback? onForcePressStart;
  final GestureForcePressPeakCallback? onForcePressPeak;
  final GestureForcePressUpdateCallback? onForcePressUpdate;
  final GestureForcePressEndCallback? onForcePressEnd;

  const GestureCallbackSet({
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onDoubleTap,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.onVerticalDragDown,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
  });

  bool get hasAny => onTapDown != null || onTapUp != null || onTap != null || onTapCancel != null || onSecondaryTapDown != null || onSecondaryTapUp != null || onSecondaryTapCancel != null || onDoubleTap != null || onLongPress != null || onLongPressStart != null || onLongPressMoveUpdate != null || onLongPressUp != null || onLongPressEnd != null || onVerticalDragDown != null || onVerticalDragStart != null || onVerticalDragUpdate != null || onVerticalDragEnd != null || onVerticalDragCancel != null || onHorizontalDragDown != null || onHorizontalDragStart != null || onHorizontalDragUpdate != null || onHorizontalDragEnd != null || onHorizontalDragCancel != null || onPanDown != null || onPanStart != null || onPanUpdate != null || onPanEnd != null || onPanCancel != null || onScaleStart != null || onScaleUpdate != null || onScaleEnd != null || onForcePressStart != null || onForcePressPeak != null || onForcePressUpdate != null || onForcePressEnd != null;
}

class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleCoefficient;
  final int duration;

  const SpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleCoefficient = 0.875,
    this.duration = 150,
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isLongPress = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleCoefficient,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _isLongPress = false;
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_isLongPress) {
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          widget.onTap?.call();
        });
      });
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    _isLongPress = true;
    _controller.forward();
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _controller.reverse().then((_) {
      widget.onTap?.call();
    });
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void triggerAnimation() {
    if (!_controller.isAnimating) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPressStart: _handleLongPressStart,
      onLongPressEnd: _handleLongPressEnd,
      behavior: HitTestBehavior.deferToChild,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: content,
      ),
    );
  }
}
