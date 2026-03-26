import '../../../core/core.dart';
import '../../../core/helpers/in_app_review/in_app_review.dart';

class ReviewRequestSection extends StatelessWidget {
  const ReviewRequestSection({super.key});

  Future<void> _handleRequestReview(BuildContext context) async {
    try {
      final success = await InAppReviewHelper.shared.requestReviewDirectly();
      if (!context.mounted) return;

      if (success) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(
              context.tr(LocaleKeys.onboarding_rating_thank_you),
            ),
            content: Text(
              context.tr(LocaleKeys.onboarding_rating_feedback_message),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.tr(LocaleKeys.onboarding_rating_continue),
                ),
              ),
            ],
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(
              context.tr(LocaleKeys.onboarding_rating_rate_title),
            ),
            content: Text(
              context.tr(LocaleKeys.onboarding_rating_rate_message),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  context.tr(LocaleKeys.onboarding_rating_continue),
                ),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            context.tr(LocaleKeys.onboarding_rating_rate_title),
          ),
          content: Text(
            context.tr(LocaleKeys.onboarding_rating_rate_message),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.tr(LocaleKeys.onboarding_rating_continue),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: CupertinoCard(
            color: CupertinoColors.systemPink,
            borderRadius: BorderRadius.circular(5),
            padding: const EdgeInsets.all(2),
            child: Icon(
              CupertinoIcons.star_fill,
              color: Colors.white.withValues(alpha: .9),
            ),
          ),
          title: Text(
            context.tr(LocaleKeys.settings_review_request_title),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            context.tr(LocaleKeys.settings_review_request_subtitle),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _handleRequestReview(context),
          trailing: const CupertinoListTileChevron(),
        ),
      ],
    );
  }
}
