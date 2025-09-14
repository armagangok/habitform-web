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

    // Default colors based on theme

    final defaultIconColor = theme.colorScheme.primary;

    final effectiveIconColor = iconColor ?? defaultIconColor;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.primaryContrastingColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
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
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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
                  size: 20,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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
