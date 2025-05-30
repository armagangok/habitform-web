import '/core/core.dart';

/// Card widget to display a single statistic with icon, title and value
class StatisticCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatisticCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CupertinoListTile(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Icon(
          icon,
          color: context.theme.primaryColor,
          size: 32,
        ),
        subtitle: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.theme.hintColor,
              ),
          maxLines: 10,
        ),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
          maxLines: 10,
        ),
      ),
    );
  }
}
