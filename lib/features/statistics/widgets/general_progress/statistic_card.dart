import '/core/core.dart';

/// Card widget to display a single statistic with optimized layout
class StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? unit;
  final Color? cardColor;
  final Color? iconColor;

  const StatisticCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.unit,
    this.cardColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors based on theme
    final defaultCardColor = isDark ? theme.colorScheme.surface.withValues(alpha: 0.1) : theme.colorScheme.surface;
    final defaultIconColor = theme.colorScheme.primary;

    final effectiveCardColor = cardColor ?? defaultCardColor;
    final effectiveIconColor = iconColor ?? defaultIconColor;

    return Container(
      height: 120, // Fixed height for consistent card sizes
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: effectiveCardColor,
        borderRadius: BorderRadius.circular(16),
        gradient: effectiveCardColor != defaultCardColor
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveCardColor,
                  effectiveCardColor.withValues(alpha: 0.8),
                ],
              )
            : null,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Right: Value and Unit
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    child: Column(
                      children: [
                        Text(
                          double.parse(value).toStringAsFixed(0),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: theme.colorScheme.onSurface,
                            height: 1.0,
                            fontFeatures: [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                          maxLines: 1,
                        ),
                        if (unit != null) ...[
                          const SizedBox(width: 3),
                          Text(
                            unit!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFeatures: [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Bottom Left: Icon and Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
