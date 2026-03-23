import '../../../core/core.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({super.key, required this.photoUrl, this.radius = 32});

  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: context.theme.selectionHandleColor.withValues(
        alpha: 0.1,
      ),
      radius: radius,
      child: ClipOval(
        child: Image.network(
          photoUrl ?? '',
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null)
              return child.animate().fadeIn(
                    duration: const Duration(milliseconds: 300),
                  );
            return CircularProgressIndicator.adaptive();
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(CupertinoIcons.person)
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300));
          },
        ),
      ),
    );
  }
}
