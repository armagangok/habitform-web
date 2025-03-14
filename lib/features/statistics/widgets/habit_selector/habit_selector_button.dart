import '/core/core.dart';

class HabitSelectorButton extends StatelessWidget {
  const HabitSelectorButton({
    super.key,
    required this.isSelected,
    required this.emoji,
    required this.habitName,
    required this.onTap,
  });

  final bool isSelected;
  final String emoji;
  final String habitName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CupertinoButton(
        onPressed: onTap,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.only(right: 20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? habitName : "",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
