import '../../../core/core.dart';
import '../../../core/helpers/in_app_review/in_app_review.dart';
import 'setting_item.dart';

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
            title: Text(LocaleKeys.onboarding_rating_thank_you.tr()),
            content: Text(LocaleKeys.onboarding_rating_feedback_message.tr()),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(LocaleKeys.onboarding_rating_continue.tr()),
              ),
            ],
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(LocaleKeys.onboarding_rating_rate_title.tr()),
            content: Text(LocaleKeys.onboarding_rating_rate_message.tr()),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(LocaleKeys.onboarding_rating_continue.tr()),
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
          title: Text(LocaleKeys.onboarding_rating_rate_title.tr()),
          content: Text(LocaleKeys.onboarding_rating_rate_message.tr()),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocaleKeys.onboarding_rating_continue.tr()),
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
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: const SettingLeadingWidget(
            iconData: CupertinoIcons.star_fill,
            cardColor: CupertinoColors.systemPink,
          ),
          title: Text(
            LocaleKeys.settings_review_request_title.tr(),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            LocaleKeys.settings_review_request_subtitle.tr(),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _handleRequestReview(context),
          trailing: CupertinoListTileChevron(),
        ),
      ],
    );
  }
}
