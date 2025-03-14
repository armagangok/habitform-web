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
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Material(
        color: Colors.transparent,
        child: CupertinoButton(
          onPressed: onTap,
          minSize: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.deepOrangeAccent : context.theme.cardTheme.color,
          pressedOpacity: .9,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? habitName : "",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? CupertinoColors.white : null,
                        ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
