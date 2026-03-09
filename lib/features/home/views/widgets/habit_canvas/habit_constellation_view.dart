import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_model.dart';
import '/models/habit/habit_summary.dart';
import '/services/habit_service/habit_service_interface.dart';
import '../../../../habit_detail/page/habit_detail.dart';
import '../../../../habit_detail/providers/habit_detail_provider.dart';
import 'circular_habit_widget.dart';
import 'connection_painter.dart';
import 'habit_canvas_provider.dart';

/// Main constellation view for habits
/// Accepts both Habit and HabitSummary for performance optimization
class HabitConstellationView extends ConsumerStatefulWidget {
  final List<dynamic> habits; // Can be List<Habit> or List<HabitSummary>

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

  // Habit name visibility state
  bool _showHabitNames = true;

  // Tap detection for empty area taps
  bool _isPanning = false;

  bool _isInitialized = false;

  // Debounce timer for saving pan/zoom state
  Timer? _saveStateTimer;
  static const Duration _saveDebounceDuration = Duration(milliseconds: 500);
  static const Duration _zoomDebounceDuration = Duration(milliseconds: 200); // Shorter debounce for zoom/pinch

  // Animation controller for smooth zoom
  late final AnimationController _zoomAnimationController;

  // Store animation listeners to properly dispose them
  VoidCallback? _currentAnimationListener;
  void Function(AnimationStatus)? _currentStatusListener;

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

    LogHelper.shared.debugPrint('🔷 [ConstellationView] _initializeCanvas started');

    // Initialize habit positions (this waits for state to be loaded first)
    await ref.read(habitCanvasProvider.notifier).initializePositions(
          widget.habits,
          canvasWidth,
          canvasHeight,
        );

    if (!mounted) return;

    // Check if user has a saved transform (matrix values)
    final canvasState = ref.read(habitCanvasProvider);
    final hasUserTransform = canvasState.hasUserTransform;
    final matrixValues = canvasState.matrixValues;

    LogHelper.shared.debugPrint('🔷 [ConstellationView] hasUserTransform: $hasUserTransform, matrixValues: ${matrixValues?.length ?? 0} values');

    if (hasUserTransform && matrixValues != null && matrixValues.length == 16) {
      // Restore saved transform state using raw matrix values
      LogHelper.shared.debugPrint('🔷 [ConstellationView] Restoring saved transform from matrix values');
      _restoreSavedTransform(matrixValues);
    } else {
      // First time or reset - center view on habits
      LogHelper.shared.debugPrint('🔷 [ConstellationView] Centering view on habits (no saved transform)');
      _centerViewOnHabits();
    }

    _isInitialized = true;
  }

  /// Restores the saved transform state from raw matrix values
  void _restoreSavedTransform(List<double> matrixValues) {
    LogHelper.shared.debugPrint('🔷 [ConstellationView] _restoreSavedTransform with ${matrixValues.length} matrix values');
    final matrix = Matrix4.fromList(matrixValues);
    LogHelper.shared.debugPrint('🔷 [ConstellationView] Restored scale: ${matrix.getMaxScaleOnAxis()}, translation: ${matrix.getTranslation()}');
    _transformationController.value = matrix;
  }

  /// Centers the view on habits, ensuring they're visible on screen
  void _centerViewOnHabits() {
    final positions = ref.read(habitCanvasProvider.select((state) => state.positions));
    final scale = ref.read(habitCanvasProvider.select((state) => state.scale));
    final screenSize = MediaQuery.of(context).size;

    if (positions.isEmpty || widget.habits.isEmpty) {
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
      final position = positions[habit.id];
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

    // Use current visible scale (from controller) or fallback to saved/default
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final finalScale = currentScale > 0 ? currentScale : (scale > 0 ? scale : 1.0);

    // Calculate offset to center habits on screen
    // Screen position = canvas position * scale + offset
    // We want: screenCenter = habitsCenter * scale + offset
    // So: offset = screenCenter - habitsCenter * scale
    final offsetX = (screenSize.width / 2) - (habitsCenterX * finalScale);
    final offsetY = (screenSize.height / 2) - (habitsCenterY * finalScale);

    // Apply the transformation: first scale, then translate
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(offsetX, offsetY, 0.0, 1.0)
      ..scaleByDouble(finalScale, finalScale, 1.0, 1.0);

    // Don't save this state - it's auto-calculated centering, not user interaction
    // User's zoom/pan state will be saved in _onInteractionEnd
  }

  /// Centers the view on habits with smooth animation
  void _centerViewOnHabitsAnimated() {
    final positions = ref.read(habitCanvasProvider.select((state) => state.positions));
    final scale = ref.read(habitCanvasProvider.select((state) => state.scale));
    final screenSize = MediaQuery.of(context).size;

    if (positions.isEmpty || widget.habits.isEmpty) {
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
      final position = positions[habit.id];
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

    // Use current visible scale (from controller) or fallback to saved/default
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    final finalScale = currentScale > 0 ? currentScale : (scale > 0 ? scale : 1.0);

    // Calculate offset to center habits on screen
    final offsetX = (screenSize.width / 2) - (habitsCenterX * finalScale);
    final offsetY = (screenSize.height / 2) - (habitsCenterY * finalScale);

    // Create target matrix
    final targetMatrix = Matrix4.identity()
      ..translateByDouble(offsetX, offsetY, 0.0, 1.0)
      ..scaleByDouble(finalScale, finalScale, 1.0, 1.0);

    // Animate to target
    _animateToMatrix(targetMatrix);
  }

  /// Animates the transformation controller to a target matrix
  void _animateToMatrix(Matrix4 targetMatrix) {
    final currentMatrix = _transformationController.value.clone();
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

    // Screen center as focal point - keep this point stable during animation
    final screenCenter = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    // Convert screen center to scene coordinates using current matrix
    // This keeps the focal point stable during animation
    final inverted = Matrix4.identity()..setFrom(currentMatrix);
    if (inverted.invert() == 0.0) {
      // Non-invertible matrix, fallback to simple interpolation
      final scaleDelta = targetScale - currentScale;
      final translationDelta = targetTranslation - currentTranslation;

      // Remove existing listeners before adding new ones
      _removeAnimationListeners();

      _zoomAnimationController.reset();

      // Create and store listener
      _currentAnimationListener = () {
        final progress = Curves.easeInOutCubic.transform(_zoomAnimationController.value);
        final animatedScale = currentScale + (scaleDelta * progress);
        final animatedTranslation = currentTranslation + (translationDelta * progress);

        final animatedMatrix = Matrix4.identity()
          ..translateByDouble(animatedTranslation.dx, animatedTranslation.dy, 0.0, 1.0)
          ..scaleByDouble(animatedScale, animatedScale, 1.0, 1.0);

        _transformationController.value = animatedMatrix;
      };
      _zoomAnimationController.addListener(_currentAnimationListener!);

      // Create and store status listener
      _currentStatusListener = (status) {
        if (status == AnimationStatus.completed) {
          final translation = targetMatrix.getTranslation();
          ref.read(habitCanvasProvider.notifier).updateScale(targetScale);
          ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
          // Clean up listeners after animation completes
          _removeAnimationListeners();
        }
      };
      _zoomAnimationController.addStatusListener(_currentStatusListener!);

      _zoomAnimationController.forward();
      return;
    }

    // Get the scene point that's currently at screen center
    final scenePoint = MatrixUtils.transformPoint(inverted, screenCenter);

    // Calculate what the target scene point should be (habits center)
    // We need to find what scene point should be at screen center in target matrix
    final targetInverted = Matrix4.identity()..setFrom(targetMatrix);
    Offset targetScenePoint;
    if (targetInverted.invert() != 0.0) {
      targetScenePoint = MatrixUtils.transformPoint(targetInverted, screenCenter);
    } else {
      // If target matrix is not invertible, use current scene point
      targetScenePoint = scenePoint;
    }

    final scaleDelta = targetScale - currentScale;
    final scenePointDelta = targetScenePoint - scenePoint;

    // Remove existing listeners before adding new ones
    _removeAnimationListeners();

    _zoomAnimationController.reset();

    // Create and store listener
    _currentAnimationListener = () {
      final progress = Curves.easeInOutCubic.transform(_zoomAnimationController.value);
      final animatedScale = currentScale + (scaleDelta * progress);
      final animatedScenePoint = scenePoint + (scenePointDelta * progress);

      // Maintain focal point: screenCenter = animatedScenePoint * animatedScale + translation
      // So: translation = screenCenter - animatedScenePoint * animatedScale
      final offsetX = screenCenter.dx - (animatedScenePoint.dx * animatedScale);
      final offsetY = screenCenter.dy - (animatedScenePoint.dy * animatedScale);

      final animatedMatrix = Matrix4.identity()
        ..translateByDouble(offsetX, offsetY, 0.0, 1.0)
        ..scaleByDouble(animatedScale, animatedScale, 1.0, 1.0);

      _transformationController.value = animatedMatrix;
    };
    _zoomAnimationController.addListener(_currentAnimationListener!);

    // Create and store status listener
    _currentStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        // Save final state after animation completes
        final finalMatrix = _transformationController.value;
        final finalScale = finalMatrix.getMaxScaleOnAxis();
        final translation = finalMatrix.getTranslation();
        ref.read(habitCanvasProvider.notifier).updateScale(finalScale);
        ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
        // Clean up listeners after animation completes
        _removeAnimationListeners();
      }
    };
    _zoomAnimationController.addStatusListener(_currentStatusListener!);

    _zoomAnimationController.forward();
  }

  @override
  void didUpdateWidget(HabitConstellationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger position update if the habits list object changes
    // This ensures we pick up position updates from remote sync even if count is same
    if (widget.habits != oldWidget.habits) {
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
    // Remove animation listeners before disposing
    if (_currentAnimationListener != null) {
      _zoomAnimationController.removeListener(_currentAnimationListener!);
      _currentAnimationListener = null;
    }
    if (_currentStatusListener != null) {
      _zoomAnimationController.removeStatusListener(_currentStatusListener!);
      _currentStatusListener = null;
    }
    _zoomAnimationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  /// Remove existing animation listeners before adding new ones
  void _removeAnimationListeners() {
    if (_currentAnimationListener != null) {
      _zoomAnimationController.removeListener(_currentAnimationListener!);
      _currentAnimationListener = null;
    }
    if (_currentStatusListener != null) {
      _zoomAnimationController.removeStatusListener(_currentStatusListener!);
      _currentStatusListener = null;
    }
  }

  // Save pan and zoom state with debounce
  void _saveTransformState({bool isZoom = false}) {
    if (_draggingHabitId != null) return; // Don't save while dragging habit

    _saveStateTimer?.cancel();
    final debounceDuration = isZoom ? _zoomDebounceDuration : _saveDebounceDuration;
    _saveStateTimer = Timer(debounceDuration, () {
      final matrix = _transformationController.value;
      final scale = matrix.getMaxScaleOnAxis();
      final translation = matrix.getTranslation();

      ref.read(habitCanvasProvider.notifier).updateScale(scale);
      ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
    });
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    LogHelper.shared.debugPrint('🟠 [ConstellationView] _onInteractionEnd called');
    if (_draggingHabitId != null) {
      LogHelper.shared.debugPrint('🟠 [ConstellationView] Skipping - dragging habit');
      return; // Don't save transform while dragging
    }

    // Reset panning flag after a short delay to allow tap detection
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isPanning = false;
      }
    });

    // Save immediately on interaction end to ensure state is persisted
    _saveStateTimer?.cancel();
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    LogHelper.shared.debugPrint('🟠 [ConstellationView] Current scale from matrix: $scale');
    final translation = matrix.getTranslation();

    // Save raw matrix values for precise restoration
    final matrixValues = matrix.storage.toList();
    LogHelper.shared.debugPrint('🟠 [ConstellationView] Saving matrix values: ${matrixValues.length} values');

    // Use immediate save to ensure state is persisted even if app closes
    ref.read(habitCanvasProvider.notifier).updateTransformImmediate(
          scale,
          translation.x,
          translation.y,
          matrixValues: matrixValues,
        );
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_draggingHabitId != null) return;

    // Track if we're panning (movement detected)
    // Only update state if it actually changes to avoid unnecessary rebuilds
    final isPanningNow = details.pointerCount > 0 || details.scale != 1.0;
    if (!_isPanning && isPanningNow) {
      _isPanning = true;
    }

    // InteractiveViewer handles pan and scale automatically
    // Save state with appropriate debounce based on interaction type
    // Zoom/pinch operations use shorter debounce for more frequent caching
    // Only save if there's actual movement or scale change (avoid work on idle frames)
    final hasMovement = details.scale != 1.0 || details.focalPointDelta != Offset.zero;
    if (hasMovement) {
      final isZoom = details.scale != 1.0;
      _saveTransformState(isZoom: isZoom);
    }
  }

  // Start dragging a habit (called on long press)
  void _startDragging(String habitId, Offset globalPosition) {
    HapticFeedback.heavyImpact();

    final positions = ref.read(habitCanvasProvider.select((state) => state.positions));
    final position = positions[habitId];
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

  // Open habit detail page, loading full habit if needed
  Future<void> _openHabitDetail(dynamic habit) async {
    // If it's a HabitSummary, load the full Habit first
    Habit fullHabit;
    if (habit is HabitSummary) {
      final loadedHabit = await habitService.getHabit(habit.id);
      if (loadedHabit == null) {
        LogHelper.shared.errorPrint('Failed to load habit: ${habit.id}');
        return;
      }
      fullHabit = loadedHabit;
    } else {
      fullHabit = habit as Habit;
    }

    // Keep provider alive by watching it BEFORE calling initHabit
    // This prevents disposal before HabitDetailPage can watch it
    final _ = ref.watch(habitDetailProvider);
    // Set state immediately (synchronous) - sheet will have state ready
    ref.read(habitDetailProvider.notifier).initHabit(fullHabit);
    // Show sheet - HabitDetailPage will also watch, keeping provider alive
    if (mounted) {
      showCupertinoSheet(
        enableDrag: false,
        context: context,
        builder: (contextFromSheet) => HabitDetailPage(),
      );
    }
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
    // Optimize: Only watch specific parts of canvas state instead of entire state
    final positions = ref.watch(habitCanvasProvider.select((state) => state.positions));
    final connections = ref.watch(habitCanvasProvider.select((state) => state.connections));
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
                // Grid background - wrapped in RepaintBoundary since it's static
                RepaintBoundary(
                  child: CustomPaint(
                    size: const Size(canvasWidth, canvasHeight),
                    painter: _GridPainter(isDark: isDark),
                  ),
                ),

                // Connection lines - already in RepaintBoundary, stays cached
                RepaintBoundary(
                  child: CustomPaint(
                    size: const Size(canvasWidth, canvasHeight),
                    painter: ConnectionPainter(
                      connections: connections,
                      positions: positions,
                      habits: widget.habits,
                      isDark: isDark,
                    ),
                  ),
                ),

                // Tap detector for empty areas (positioned before habit items so they're on top)
                // This catches taps that don't hit habit items
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _isPanning,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (_) {
                        _isPanning = false; // Reset panning flag on tap down
                      },
                      onTap: () {
                        // Only toggle if not panning and not in special modes
                        if (!_isPanning && _draggingHabitId == null && !_isConnectingMode) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _showHabitNames = !_showHabitNames;
                          });
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),

                // Habit items
                ...widget.habits.map((habit) {
                  final position = positions[habit.id];
                  if (position == null) return const SizedBox.shrink();

                  final isDragging = _draggingHabitId == habit.id;
                  final isSelectedForConnection = _selectedHabitForConnection == habit.id;

                  return Positioned(
                    key: ValueKey('habit_${habit.id}'),
                    left: position.x - 55,
                    top: position.y - 70,
                    child: RepaintBoundary(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          // Don't handle tap if we're in dragging mode
                          if (_draggingHabitId != null) return;

                          if (_isConnectingMode) {
                            _onHabitTapForConnection(habit.id);
                          } else {
                            // Load full habit if we have a summary, otherwise use the habit directly
                            _openHabitDetail(habit);
                          }
                        },
                        onLongPressStart: (details) {
                          _startDragging(habit.id, details.globalPosition);
                        },
                        onLongPressMoveUpdate: (details) {
                          if (_draggingHabitId == habit.id) {
                            _updateDragPosition(details.globalPosition);
                          }
                        },
                        onLongPressEnd: (_) {
                          // Don't end dragging on long press end, let overlay handle it
                          // This allows dragging to continue even after finger is lifted
                        },
                        child: CircularHabitWidget(
                          key: ValueKey(habit.id),
                          habit: habit,
                          isSelected: isSelectedForConnection,
                          isDragging: isDragging,
                          isConnecting: _isConnectingMode,
                          showName: _showHabitNames,
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
        // This allows dragging even after finger is lifted and placed again
        if (_draggingHabitId != null)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                _updateDragPosition(details.globalPosition);
              },
              onPanEnd: (_) => _endDragging(),
              onPanCancel: _endDragging,
              onTap: () {
                // End dragging on tap
                _endDragging();
              },
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
          child: IgnorePointer(
            ignoring: !(_showHabitNames && _draggingHabitId == null),
            child: AnimatedOpacity(
              opacity: (_showHabitNames && _draggingHabitId == null) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  _buildControlButton(
                    icon: CupertinoIcons.zoom_in,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final currentScale = _transformationController.value.getMaxScaleOnAxis();
                      _animateScale(currentScale * 1.3);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildControlButton(
                    icon: CupertinoIcons.zoom_out,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final currentScale = _transformationController.value.getMaxScaleOnAxis();

                      // Match the minScale from InteractiveViewer (0.3)
                      const minScale = 0.3;

                      // If already at or very close to minimum scale, do nothing
                      if (currentScale <= minScale + 0.01) {
                        return;
                      }

                      // Calculate target scale (zoom out by factor of 1.3)
                      var targetScale = currentScale / 1.3;

                      // Clamp to minimum scale
                      if (targetScale < minScale) {
                        targetScale = minScale;
                      }

                      _animateScale(targetScale);
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
          ),
        ),

        // Connection mode button (left side)
        Positioned(
          left: 16,
          bottom: MediaQuery.of(context).padding.bottom + 100,
          child: IgnorePointer(
            ignoring: !(_showHabitNames && _draggingHabitId == null),
            child: AnimatedOpacity(
              opacity: (_showHabitNames && _draggingHabitId == null) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildControlButton(
                icon: _isConnectingMode ? CupertinoIcons.link_circle_fill : CupertinoIcons.link,
                onTap: _toggleConnectingMode,
                isDark: isDark,
                isActive: _isConnectingMode,
              ),
            ),
          ),
        ),

        // Instructions hint (bottom center)
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 20,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: (_showHabitNames && _draggingHabitId == null) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _draggingHabitId != null ? LocaleKeys.home_release_to_place.tr() : LocaleKeys.home_long_press_to_move.tr(),
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
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
    return CustomBlurWidget(
      borderRadius: BorderRadius.circular(999),
      child: CustomButton(
        onPressed: onTap,
        child: CupertinoCard(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: context.cupertinoTheme.primaryContrastingColor.withValues(alpha: 0.125),
                width: .7,
              ),
              color: isActive ? CupertinoColors.activeGreen : context.cupertinoTheme.selectionHandleColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.cupertinoTheme.primaryContrastingColor.withValues(alpha: 0.125),
                  blurRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: isActive ? Colors.white : context.cupertinoTheme.primaryContrastingColor.withValues(alpha: .8),
            ),
          ),
        ),
      ),
    );
  }

  void _animateScale(double targetScale) {
    final clampedScale = targetScale.clamp(0.3, 3.0);
    final currentMatrix = _transformationController.value.clone();
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    // Skip if already at target (with small tolerance)
    if ((clampedScale - currentScale).abs() < 0.001) {
      return;
    }

    // Screen center as focal point
    final screenCenter = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    // Convert screen center to scene coordinates to keep it stable during scaling
    final inverted = Matrix4.identity()..setFrom(currentMatrix);
    if (inverted.invert() == 0.0) return; // Non-invertible matrix, skip
    final sceneCenter = MatrixUtils.transformPoint(inverted, screenCenter);

    final startScale = currentScale;
    final scaleDelta = clampedScale - startScale;

    // Remove existing listeners before adding new ones
    _removeAnimationListeners();

    _zoomAnimationController.reset();

    // Create and store listener
    _currentAnimationListener = () {
      final progress = Curves.easeInOutCubic.transform(_zoomAnimationController.value);
      final animatedScale = (startScale + (scaleDelta * progress)).clamp(0.3, 3.0);

      // Maintain focal point: screenCenter = sceneCenter * scale + translation
      final offsetX = screenCenter.dx - (sceneCenter.dx * animatedScale);
      final offsetY = screenCenter.dy - (sceneCenter.dy * animatedScale);

      final animatedMatrix = Matrix4.identity()
        ..translateByDouble(offsetX, offsetY, 0.0, 1.0)
        ..scaleByDouble(animatedScale, animatedScale, 1.0, 1.0);

      _transformationController.value = animatedMatrix;
    };
    _zoomAnimationController.addListener(_currentAnimationListener!);

    // Create and store status listener
    _currentStatusListener = (status) {
      if (status == AnimationStatus.completed) {
        // Save final state after animation completes
        final finalMatrix = _transformationController.value;
        final finalScale = finalMatrix.getMaxScaleOnAxis();

        final translation = finalMatrix.getTranslation();
        ref.read(habitCanvasProvider.notifier).updateScale(finalScale);
        ref.read(habitCanvasProvider.notifier).updateOffset(translation.x, translation.y);
        // Clean up listeners after animation completes
        _removeAnimationListeners();
      }
    };
    _zoomAnimationController.addStatusListener(_currentStatusListener!);

    _zoomAnimationController.forward();
  }
}

/// Grid background painter - optimized with Path batching and caching
class _GridPainter extends CustomPainter {
  final bool isDark;

  // Static cache for grid paths to avoid recalculation
  static Path? _cachedPath;
  static Size? _cachedSize;

  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.175) : Colors.black.withValues(alpha: 0.175)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Use cached path if size matches
    if (_cachedPath != null && _cachedSize == size) {
      canvas.drawPath(_cachedPath!, paint);
      return;
    }

    // Build path with all grid lines (batch drawing is faster than individual lines)
    const spacing = 50.0;
    final path = Path();

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      path.moveTo(x, 0);
      path.lineTo(x, size.height);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }

    // Cache the path
    _cachedPath = path;
    _cachedSize = size;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
