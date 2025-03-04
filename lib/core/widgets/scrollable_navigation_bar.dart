import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

/// A navigation bar that automatically hides when scrolling down and shows when scrolling up
/// near the top of the scroll view.
class ScrollableNavigationBar extends StatefulWidget {
  /// The navigation bar widget to display
  final Widget navigationBar;

  /// The scroll controller to listen to
  final ScrollController scrollController;

  /// The threshold (in pixels) for showing the navbar when scrolling up
  final double showThreshold;

  /// The minimum scroll delta required to trigger navbar visibility change
  final double scrollDeltaThreshold;

  /// The duration of the show/hide animation
  final Duration animationDuration;

  /// The curve of the show/hide animation
  final Curve animationCurve;

  /// Whether to apply a backdrop filter for blur effect
  final bool enableBlur;

  /// The blur intensity for the backdrop filter
  final double blurIntensity;

  const ScrollableNavigationBar({
    super.key,
    required this.navigationBar,
    required this.scrollController,
    this.showThreshold = 80.0,
    this.scrollDeltaThreshold = 50.0,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeInOut,
    this.enableBlur = true,
    this.blurIntensity = 10.0,
  });

  @override
  State<ScrollableNavigationBar> createState() => _ScrollableNavigationBarState();
}

class _ScrollableNavigationBarState extends State<ScrollableNavigationBar> with SingleTickerProviderStateMixin {
  bool _isNavBarVisible = true;
  double _lastScrollPosition = 0;
  double _scrollDelta = 0;
  Timer? _scrollEndTimer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    // Create animation for both position and opacity
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    // Set initial value
    _animationController.value = 1.0;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _scrollEndTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ScrollableNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }

    // Update animation duration if it changed
    if (oldWidget.animationDuration != widget.animationDuration) {
      _animationController.duration = widget.animationDuration;
    }

    // Update animation curve if it changed
    if (oldWidget.animationCurve != widget.animationCurve) {
      _animation = CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      );
    }
  }

  void _onScroll() {
    if (!widget.scrollController.hasClients) return;

    // Get current scroll position
    final currentPosition = widget.scrollController.position.pixels;
    final isScrollingDown = currentPosition > _lastScrollPosition;

    // Calculate scroll delta (how much was scrolled since last update)
    _scrollDelta += (currentPosition - _lastScrollPosition).abs();
    _lastScrollPosition = currentPosition;

    // Cancel any existing timer
    _scrollEndTimer?.cancel();

    // Reset scroll delta after a short delay (to detect quick successive scrolls)
    _scrollEndTimer = Timer(Duration(milliseconds: 100), () {
      _scrollDelta = 0;
    });

    // At the top of the list, always show the navbar
    if (currentPosition <= 0) {
      if (!_isNavBarVisible) {
        setState(() => _isNavBarVisible = true);
        _animationController.forward();
      }
      return;
    }

    // Update navbar visibility based on scroll direction and position
    if (isScrollingDown && _isNavBarVisible && _scrollDelta > widget.scrollDeltaThreshold) {
      // When scrolling down significantly, hide the navbar
      setState(() => _isNavBarVisible = false);
      _animationController.reverse();
      _scrollDelta = 0;
    } else if (!isScrollingDown && !_isNavBarVisible && (_scrollDelta > widget.scrollDeltaThreshold || currentPosition < widget.showThreshold)) {
      // Show navbar when:
      // 1. Scrolling up significantly OR
      // 2. Near the top of the list
      setState(() => _isNavBarVisible = true);
      _animationController.forward();
      _scrollDelta = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the height of the navigation bar
    final navBarHeight = 44.0; // CupertinoNavigationBar default height
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final fullNavBarHeight = navBarHeight + statusBarHeight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: -navBarHeight * (1 - _animation.value),
          left: 0,
          right: 0,
          height: fullNavBarHeight,
          child: ClipRect(
            child: widget.enableBlur
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blurIntensity * _animation.value,
                      sigmaY: widget.blurIntensity * _animation.value,
                    ),
                    child: Opacity(
                      opacity: _animation.value,
                      child: widget.navigationBar,
                    ),
                  )
                : Opacity(
                    opacity: _animation.value,
                    child: widget.navigationBar,
                  ),
          ),
        );
      },
    );
  }
}

/// Extension to add scrollable behavior to a CupertinoNavigationBar
extension ScrollableCupertinoNavigationBarExtension on CupertinoNavigationBar {
  /// Creates a scrollable version of this navigation bar
  ScrollableNavigationBar scrollable({
    required ScrollController scrollController,
    double showThreshold = 80.0,
    double scrollDeltaThreshold = 50.0,
    Duration animationDuration = const Duration(milliseconds: 350),
    Curve animationCurve = Curves.easeInOut,
    bool enableBlur = true,
    double blurIntensity = 10.0,
  }) {
    // Create a copy of the navigation bar with a unique heroTag to avoid conflicts
    final navBarWithUniqueHeroTag = CupertinoNavigationBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      automaticallyImplyMiddle: automaticallyImplyMiddle,
      previousPageTitle: previousPageTitle,
      middle: middle,
      trailing: trailing,
      border: border,
      backgroundColor: backgroundColor,
      brightness: brightness,
      padding: padding,
      transitionBetweenRoutes: transitionBetweenRoutes,
      heroTag: 'scrollable_nav_bar_${scrollController.hashCode}', // Unique heroTag
    );

    return ScrollableNavigationBar(
      navigationBar: navBarWithUniqueHeroTag,
      scrollController: scrollController,
      showThreshold: showThreshold,
      scrollDeltaThreshold: scrollDeltaThreshold,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      enableBlur: enableBlur,
      blurIntensity: blurIntensity,
    );
  }
}
