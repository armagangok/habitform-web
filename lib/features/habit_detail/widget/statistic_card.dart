import '/core/core.dart';

/// Card widget to display a single statistic with optimized layout
class StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? unit;
  final Color? cardColor;
  final Color? iconColor;
  final Color? valueColor;
  final Color? titleColor;

  const StatisticCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.unit,
    this.cardColor,
    this.iconColor,
    this.valueColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    // Default colors based on theme

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardColor ?? context.primaryContrastingColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Right: Value and Unit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor?.withValues(alpha: 1) ?? context.primaryContrastingColor.withValues(alpha: 0.15),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    child: Column(
                      children: [
                        Text(
                          double.parse(value).toStringAsFixed(0),
                          style: context.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            height: 1.0,
                            color: valueColor ?? context.cupertinoTheme.textTheme.textStyle.color,
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
                            style: context.bodySmall.copyWith(
                              color: (valueColor ?? context.cupertinoTheme.textTheme.textStyle.color)?.withValues(alpha: 0.7),
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
              Text(
                title,
                style: context.bodyMedium.copyWith(
                  color: titleColor ?? context.primaryContrastingColor.withValues(alpha: 0.7),
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
