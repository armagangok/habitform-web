import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/models/habit/habit_extension.dart';
import '/models/habit/habit_model.dart';
import '../../../provider/home_provider.dart';

/// Circular habit item for the constellation view
class CircularHabitWidget extends ConsumerStatefulWidget {
  final Habit habit;
  final bool isSelected;
  final bool isDragging;
  final bool isConnecting;
  final VoidCallback? onComplete;
  final bool? showName;

  const CircularHabitWidget({
    super.key,
    required this.habit,
    this.isSelected = false,
    this.isDragging = false,
    this.isConnecting = false,
    this.onComplete,
    this.showName,
  });

  @override
  ConsumerState<CircularHabitWidget> createState() => _CircularHabitWidgetState();
}

class _CircularHabitWidgetState extends ConsumerState<CircularHabitWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleCompletion() async {
    if (!mounted) return;

    HapticFeedback.mediumImpact();

    final today = DateTime.now();
    final homeNotifier = ref.read(homeProvider.notifier);
    final currentHabit = ref.read(homeProvider).maybeWhen(
          data: (homeState) => homeState.habits.firstWhere(
            (h) => h.id == widget.habit.id,
            orElse: () => widget.habit,
          ),
          orElse: () => widget.habit,
        );

    final count = currentHabit.getCountForDate(today);
    final target = currentHabit.dailyTarget <= 0 ? 1 : currentHabit.dailyTarget;
    final isCompleted = count >= target;

    await homeNotifier.adjustHabitCompletion(
      widget.habit.id,
      today,
      increment: !isCompleted,
    );

    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentHabit = ref.watch(homeProvider).maybeWhen(
          data: (homeState) => homeState.habits.firstWhere(
            (h) => h.id == widget.habit.id,
            orElse: () => widget.habit,
          ),
          orElse: () => widget.habit,
        );

    final today = DateTime.now();
    final count = currentHabit.getCountForDate(today);
    final target = currentHabit.dailyTarget <= 0 ? 1 : currentHabit.dailyTarget;
    final ratio = (count / target).clamp(0.0, 1.0);
    final isCompleted = ratio >= 1.0;

    final habitColor = Color(currentHabit.colorCode);
    final emoji = currentHabit.emoji ?? '🎯';
    final streak = currentHabit.calculateCurrentStreak();

    // Handle pulse animation
    if (isCompleted && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isCompleted && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    const double size = 90.0;
    final isDark = CupertinoTheme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = isCompleted ? 1.0 : _pulseAnimation.value;
        final dragScale = widget.isDragging ? 1.15 : 1.0;
        return Transform.scale(scale: scale * dragScale, child: child);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isDragging ? 0.9 : 1.0,
        child: SizedBox(
          width: size + 20,
          height: size + 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main circular item
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? CupertinoColors.systemGrey6.darkColor : Colors.white,
                  border: Border.all(
                    color: widget.isSelected || widget.isDragging
                        ? habitColor
                        : widget.isConnecting
                            ? habitColor
                            : isCompleted
                                ? habitColor
                                : habitColor.withValues(alpha: 0.4),
                    width: widget.isSelected || widget.isDragging ? 3.5 : 2.5,
                  ),
                  boxShadow: [
                    if (widget.isDragging) ...[
                      BoxShadow(
                        color: habitColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ] else if (isCompleted) ...[
                      BoxShadow(
                        color: habitColor.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ] else ...[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress ring
                    if (!isCompleted)
                      CustomPaint(
                        size: Size(size - 10, size - 10),
                        painter: _CircularProgressPainter(
                          progress: ratio,
                          color: habitColor,
                          backgroundColor: habitColor.withValues(alpha: 0.15),
                          strokeWidth: 4,
                        ),
                      ),

                    // Emoji
                    Text(
                      emoji,
                      style: TextStyle(fontSize: isCompleted ? 38 : 34),
                    ),

                    // Streak badge (top right)
                    if (streak > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: habitColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: habitColor.withValues(alpha: 0.5),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.flame_fill,
                                size: 11,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$streak',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Complete button (bottom right)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _toggleCompletion,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted ? habitColor : Colors.transparent,
                            border: Border.all(
                              color: habitColor,
                              width: 2.5,
                            ),
                            boxShadow: isCompleted
                                ? [
                                    BoxShadow(
                                      color: habitColor.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isCompleted ? CupertinoIcons.checkmark : CupertinoIcons.plus,
                            size: 16,
                            color: isCompleted ? Colors.white : habitColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Habit name (with animation support)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: widget.showName ?? true ? 1.0 : 0.0,
                child: SizedBox(
                  width: size + 20,
                  child: Text(
                    currentHabit.habitName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
