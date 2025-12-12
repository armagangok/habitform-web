import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_model.dart';
import '../../../../habit_detail/page/habit_detail.dart';
import '../../../../habit_detail/providers/habit_detail_provider.dart';
import 'circular_habit_item.dart';
import 'connection_painter.dart';
import 'habit_canvas_provider.dart';

/// Main constellation view for habits
class HabitConstellationView extends ConsumerStatefulWidget {
  final List<Habit> habits;

  const HabitConstellationView({
    super.key,
    required this.habits,
  });

  @override
  ConsumerState<HabitConstellationView> createState() => _HabitConstellationViewState();
}

class _HabitConstellationViewState extends ConsumerState<HabitConstellationView> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();

  // Drag state
  String? _draggingHabitId;
  Offset? _dragStartPosition;
  Offset? _habitStartPosition;

  // Connection state
  String? _selectedHabitForConnection;
  bool _isConnectingMode = false;

  bool _isInitialized = false;

  // Debounce timer for saving pan/zoom state
  Timer? _saveStateTimer;
  static const Duration _saveDebounceDuration = Duration(milliseconds: 500);

  // Animation controller for smooth zoom
  late final AnimationController _zoomAnimationController;

  // Canvas virtual size
  static const double canvasWidth = 2000.0;
  static const double canvasHeight = 2000.0;

  @override
  void initState() {
    super.initState();
    _zoomAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCanvas();
    });
  }

  Future<void> _initializeCanvas() async {
    if (_isInitialized) return;

    // Initialize habit positions (this waits for state to be loaded first)
    await ref.read(habitCanvasProvider.notifier).initializePositions(
          widget.habits,
          canvasWidth,
          canvasHeight,
        );

    if (!mounted) return;

    // Always center the view on habits for consistent behavior
    // This ensures habits are always visible when app opens
    _centerViewOnHabits();

    _isInitialized = true;
  }

  /// Centers the view on habits, ensuring they're visible on screen
  void _centerViewOnHabits() {
    final canvasState = ref.read(habitCanvasProvider);
    final screenSize = MediaQuery.of(context).size;

    if (canvasState.positions.isEmpty || widget.habits.isEmpty) {
      // No habits, just center on canvas center
      final centerOffsetX = -(canvasWidth - screenSize.width) / 2;
      final centerOffsetY = -(canvasHeight - screenSize.height) / 2;
      _transformationController.value = Matrix4.identity()..translateByDouble(centerOffsetX, centerOffsetY, 0.0, 1.0);
      return;
    }

    // Calculate the bounding box of all habits
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final habit in widget.habits) {
      final position = canvasState.positions[habit.id];
      if (position != null) {
        minX = minX < position.x ? minX : position.x;
        maxX = maxX > position.x ? maxX : position.x;
        minY = minY < position.y ? minY : position.y;
        maxY = maxY > position.y ? maxY : position.y;
      }
    }

    if (minX == double.infinity) {
      // No valid positions found, center on canvas
      final centerOffsetX = -(canvasWidth - screenSize.width) / 2;
      final centerOffsetY = -(canvasHeight - screenSize.height) / 2;
      _transformationController.value = Matrix4.identity()..translateByDouble(centerOffsetX, centerOffsetY, 0.0, 1.0);
      return;
    }

    // Calculate center of all habits
    final habitsCenterX = (minX + maxX) / 2;
    final habitsCenterY = (minY + maxY) / 2;

    // Use saved scale or default to 1.0
    final scale = canvasState.scale > 0 ? canvasState.scale : 1.0;

    // Calculate offset to center habits on screen
    // Screen position = canvas position * scale + offset
    // We want: screenCenter = habitsCenter * scale + offset
    // So: offset = screenCenter - habitsCenter * scale
    final offsetX = (screenSize.width / 2) - (habitsCenterX * scale);
    final offsetY = (screenSize.height / 2) - (habitsCenterY * scale);

    // Apply the transformation: first scale, then translate
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(offsetX, offsetY, 0.0, 1.0)
      ..scaleByDouble(scale, scale, 1.0, 1.0);

    // Save this state
    final translation = _transformationController.value.getTranslation();
    ref.read(habitCanvasProvider.notifier).updateScale(scale);
    ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
  }

  /// Centers the view on habits with smooth animation
  void _centerViewOnHabitsAnimated() {
    final canvasState = ref.read(habitCanvasProvider);
    final screenSize = MediaQuery.of(context).size;

    if (canvasState.positions.isEmpty || widget.habits.isEmpty) {
      // No habits, just center on canvas center
      final centerOffsetX = -(canvasWidth - screenSize.width) / 2;
      final centerOffsetY = -(canvasHeight - screenSize.height) / 2;
      final targetMatrix = Matrix4.identity()..translateByDouble(centerOffsetX, centerOffsetY, 0.0, 1.0);
      _animateToMatrix(targetMatrix);
      return;
    }

    // Calculate the bounding box of all habits
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final habit in widget.habits) {
      final position = canvasState.positions[habit.id];
      if (position != null) {
        minX = minX < position.x ? minX : position.x;
        maxX = maxX > position.x ? maxX : position.x;
        minY = minY < position.y ? minY : position.y;
        maxY = maxY > position.y ? maxY : position.y;
      }
    }

    if (minX == double.infinity) {
      // No valid positions found, center on canvas
      final centerOffsetX = -(canvasWidth - screenSize.width) / 2;
      final centerOffsetY = -(canvasHeight - screenSize.height) / 2;
      final targetMatrix = Matrix4.identity()..translateByDouble(centerOffsetX, centerOffsetY, 0.0, 1.0);
      _animateToMatrix(targetMatrix);
      return;
    }

    // Calculate center of all habits
    final habitsCenterX = (minX + maxX) / 2;
    final habitsCenterY = (minY + maxY) / 2;

    // Use saved scale or default to 1.0
    final scale = canvasState.scale > 0 ? canvasState.scale : 1.0;

    // Calculate offset to center habits on screen
    final offsetX = (screenSize.width / 2) - (habitsCenterX * scale);
    final offsetY = (screenSize.height / 2) - (habitsCenterY * scale);

    // Create target matrix
    final targetMatrix = Matrix4.identity()
      ..translateByDouble(offsetX, offsetY, 0.0, 1.0)
      ..scaleByDouble(scale, scale, 1.0, 1.0);

    // Animate to target
    _animateToMatrix(targetMatrix);
  }

  /// Animates the transformation controller to a target matrix
  void _animateToMatrix(Matrix4 targetMatrix) {
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    final currentTranslationVec = currentMatrix.getTranslation();
    final currentTranslation = Offset(currentTranslationVec.x, currentTranslationVec.y);

    final targetScale = targetMatrix.getMaxScaleOnAxis();
    final targetTranslationVec = targetMatrix.getTranslation();
    final targetTranslation = Offset(targetTranslationVec.x, targetTranslationVec.y);

    // Check if already at target
    if ((currentScale - targetScale).abs() < 0.01 && (currentTranslation.dx - targetTranslation.dx).abs() < 1.0 && (currentTranslation.dy - targetTranslation.dy).abs() < 1.0) {
      // Already at target, just set it
      _transformationController.value = targetMatrix;
      final translation = targetMatrix.getTranslation();
      ref.read(habitCanvasProvider.notifier).updateScale(targetScale);
      ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
      return;
    }

    final scaleDelta = targetScale - currentScale;
    final translationDelta = targetTranslation - currentTranslation;

    _zoomAnimationController.reset();
    _zoomAnimationController.addListener(() {
      final progress = Curves.easeInOutCubic.transform(_zoomAnimationController.value);
      final animatedScale = currentScale + (scaleDelta * progress);
      final animatedTranslation = currentTranslation + (translationDelta * progress);

      final animatedMatrix = Matrix4.identity()
        ..translateByDouble(animatedTranslation.dx, animatedTranslation.dy, 0.0, 1.0)
        ..scaleByDouble(animatedScale, animatedScale, 1.0, 1.0);

      _transformationController.value = animatedMatrix;
    });

    _zoomAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Save final state after animation completes
        final translation = targetMatrix.getTranslation();
        ref.read(habitCanvasProvider.notifier).updateScale(targetScale);
        ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
      }
    });

    _zoomAnimationController.forward();
  }

  @override
  void didUpdateWidget(HabitConstellationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habits.length != oldWidget.habits.length) {
      _updateHabitPositions();
    }
  }

  Future<void> _updateHabitPositions() async {
    await ref.read(habitCanvasProvider.notifier).initializePositions(
          widget.habits,
          canvasWidth,
          canvasHeight,
        );
  }

  @override
  void dispose() {
    _saveStateTimer?.cancel();
    _zoomAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  // Save pan and zoom state with debounce
  void _saveTransformState() {
    if (_draggingHabitId != null) return; // Don't save while dragging habit

    _saveStateTimer?.cancel();
    _saveStateTimer = Timer(_saveDebounceDuration, () {
      final matrix = _transformationController.value;
      final scale = matrix.getMaxScaleOnAxis();
      final translation = matrix.getTranslation();

      ref.read(habitCanvasProvider.notifier).updateScale(scale);
      ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
    });
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_draggingHabitId != null) return; // Don't save transform while dragging

    // Save immediately on interaction end
    _saveStateTimer?.cancel();
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();

    ref.read(habitCanvasProvider.notifier).updateScale(scale);
    ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_draggingHabitId != null) return;

    // InteractiveViewer handles pan and scale automatically
    // We just need to save the state with debounce
    _saveTransformState();
  }

  // Start dragging a habit (called on long press)
  void _startDragging(String habitId, Offset globalPosition) {
    HapticFeedback.heavyImpact();

    final canvasState = ref.read(habitCanvasProvider);
    final position = canvasState.positions[habitId];
    if (position == null) return;

    setState(() {
      _draggingHabitId = habitId;
      _dragStartPosition = globalPosition;
      _habitStartPosition = Offset(position.x, position.y);
    });
  }

  // Update position while dragging
  void _updateDragPosition(Offset globalPosition) {
    if (_draggingHabitId == null || _dragStartPosition == null || _habitStartPosition == null) return;

    // Calculate delta in screen space
    final screenDelta = globalPosition - _dragStartPosition!;

    // Convert delta to canvas space (account for zoom)
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final canvasDelta = screenDelta / scale;

    // Calculate new position
    final newX = _habitStartPosition!.dx + canvasDelta.dx;
    final newY = _habitStartPosition!.dy + canvasDelta.dy;

    // Update position
    ref.read(habitCanvasProvider.notifier).updatePosition(
          _draggingHabitId!,
          newX.clamp(50, canvasWidth - 50),
          newY.clamp(50, canvasHeight - 50),
        );
  }

  // End dragging
  void _endDragging() {
    if (_draggingHabitId != null) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      _draggingHabitId = null;
      _dragStartPosition = null;
      _habitStartPosition = null;
    });
  }

  // Toggle connection mode
  void _toggleConnectingMode() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isConnectingMode = !_isConnectingMode;
      _selectedHabitForConnection = null;
    });
  }

  // Handle tap on habit for connection
  void _onHabitTapForConnection(String habitId) {
    if (!_isConnectingMode) return;

    HapticFeedback.selectionClick();

    if (_selectedHabitForConnection == null) {
      setState(() {
        _selectedHabitForConnection = habitId;
      });
    } else {
      if (_selectedHabitForConnection != habitId) {
        ref.read(habitCanvasProvider.notifier).toggleConnection(
              _selectedHabitForConnection!,
              habitId,
            );
        HapticFeedback.mediumImpact();
      }
      setState(() {
        _selectedHabitForConnection = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(habitCanvasProvider);
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main interactive canvas
        InteractiveViewer(
          transformationController: _transformationController,
          onInteractionEnd: _onInteractionEnd,
          onInteractionUpdate: _onInteractionUpdate,
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.3,
          maxScale: 3.0,
          // Enable both pan and scale - InteractiveViewer handles gestures properly
          panEnabled: _draggingHabitId == null,
          scaleEnabled: true,
          constrained: false,
          clipBehavior: Clip.none,
          child: SizedBox(
            width: canvasWidth,
            height: canvasHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Grid background
                CustomPaint(
                  size: const Size(canvasWidth, canvasHeight),
                  painter: _GridPainter(isDark: isDark),
                ),

                // Connection lines
                RepaintBoundary(
                  child: CustomPaint(
                    size: const Size(canvasWidth, canvasHeight),
                    painter: ConnectionPainter(
                      connections: canvasState.connections,
                      positions: canvasState.positions,
                      habits: widget.habits,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Habit items
                ...widget.habits.map((habit) {
                  final position = canvasState.positions[habit.id];
                  if (position == null) return const SizedBox.shrink();

                  final isDragging = _draggingHabitId == habit.id;
                  final isSelectedForConnection = _selectedHabitForConnection == habit.id;

                  return Positioned(
                    left: position.x - 55,
                    top: position.y - 70,
                    child: RepaintBoundary(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onLongPressStart: (details) {
                          _startDragging(habit.id, details.globalPosition);
                        },
                        child: CircularHabitWidget(
                          habit: habit,
                          isSelected: isSelectedForConnection,
                          isDragging: isDragging,
                          isConnecting: _isConnectingMode,
                          onTap: () async {
                            if (_isConnectingMode) {
                              _onHabitTapForConnection(habit.id);
                            } else {
                              await ref.watch(habitDetailProvider.notifier).initHabit(habit);
                              if (!context.mounted) return;
                              // Use rootNavigator context to ensure sheet appears on top
                              showCupertinoSheet(
                                enableDrag: false,
                                context: context,
                                builder: (contextFromSheet) => HabitDetailPage(),
                              );
                            }
                          },
                          onLongPressStart: (pos) => _startDragging(habit.id, pos),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Dragging overlay - captures all gestures during drag
        if (_draggingHabitId != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                _updateDragPosition(details.globalPosition);
              },
              onPanEnd: (_) => _endDragging(),
              onPanCancel: _endDragging,
            ),
          ),

        // Connection mode indicator
        if (_isConnectingMode)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeGreen,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.activeGreen.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.link,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedHabitForConnection == null ? 'Tap a habit to start connecting' : 'Tap another habit to connect',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _toggleConnectingMode,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.xmark,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Zoom controls (right side)
        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 100,
          child: Column(
            children: [
              _buildControlButton(
                icon: CupertinoIcons.plus,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final currentScale = _transformationController.value.getMaxScaleOnAxis();
                  _animateScale(currentScale * 1.3);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildControlButton(
                icon: CupertinoIcons.minus,
                onTap: () {
                  HapticFeedback.lightImpact();
                  final currentScale = _transformationController.value.getMaxScaleOnAxis();
                  _animateScale(currentScale / 1.3);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildControlButton(
                icon: CupertinoIcons.compass,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _centerViewOnHabitsAnimated();
                },
                isDark: isDark,
              ),
            ],
          ),
        ),

        // Connection mode button (left side)
        Positioned(
          left: 16,
          bottom: MediaQuery.of(context).padding.bottom + 100,
          child: _buildControlButton(
            icon: _isConnectingMode ? CupertinoIcons.link_circle_fill : CupertinoIcons.link,
            onTap: _toggleConnectingMode,
            isDark: isDark,
            isActive: _isConnectingMode,
          ),
        ),

        // Instructions hint (bottom center)
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _draggingHabitId != null ? 'Release to place' : 'Long press to move • Tap for details • Double tap to complete',
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive
              ? CupertinoColors.activeGreen
              : isDark
                  ? CupertinoColors.systemGrey6.darkColor
                  : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: isActive
              ? Colors.white
              : isDark
                  ? Colors.white70
                  : Colors.black87,
        ),
      ),
    );
  }

  void _animateScale(double targetScale) {
    final clampedScale = targetScale.clamp(0.3, 3.0);
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    if ((clampedScale - currentScale).abs() < 0.01) return; // Already at target

    final startScale = currentScale;
    final scaleDelta = clampedScale - startScale;

    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    _zoomAnimationController.reset();
    _zoomAnimationController.addListener(() {
      final progress = Curves.easeInOutCubic.transform(_zoomAnimationController.value);
      final animatedScale = startScale + (scaleDelta * progress);
      final scaleFactor = animatedScale / startScale;

      final animatedMatrix = currentMatrix.clone()
        ..translateByDouble(center.dx, center.dy, 0.0, 1.0)
        ..scaleByDouble(scaleFactor, scaleFactor, 1.0, 1.0)
        ..translateByDouble(-center.dx, -center.dy, 0.0, 1.0);

      _transformationController.value = animatedMatrix;
    });

    _zoomAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Save final state after animation completes
        ref.read(habitCanvasProvider.notifier).updateScale(clampedScale);
        final finalMatrix = _transformationController.value;
        final translation = finalMatrix.getTranslation();
        ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
      }
    });

    _zoomAnimationController.forward();
  }
}

/// Grid background painter
class _GridPainter extends CustomPainter {
  final bool isDark;

  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const spacing = 50.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
