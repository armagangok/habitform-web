import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/core/core.dart';
import '/features/purchase/providers/purchase_provider.dart';
import '/features/settings/widgets/subscribe_button.dart';
import '../../../core/widgets/custom_list_tile.dart';

class ProFeaturesPage extends ConsumerWidget {
  const ProFeaturesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProUser = ref.watch(purchaseProvider).valueOrNull?.isSubscriptionActive ?? false;
    final features = _buildFeatures();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(context.tr('settings.pro_features.title')),
        previousPageTitle: context.tr('settings.settings'),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Habit",
                              style: context.headlineMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "Form",
                              style: context.headlineMedium.copyWith(
                                color: context.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CupertinoCard(
                          color: context.primary,
                          elevation: 0,
                          borderRadius: BorderRadius.circular(99),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          child: Text(
                            "PRO",
                            style: context.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr(LocaleKeys.onboarding_app_features_subtitle),
                    style: context.bodyMedium.copyWith(
                      color: context.cupertinoTextTheme.textStyle.color?.withValues(alpha: 0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ...features.map(
              (feature) => CustomSection(
                footer: Text(
                  context.tr(feature.descriptionKey),
                  style: context.bodySmall.copyWith(
                    color: context.cupertinoTextTheme.textStyle.color?.withValues(alpha: 0.75),
                  ),
                ),
                child: CustomListTile(
                  leading: CupertinoCard(
                    color: feature.color,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.all(2),
                    child: Icon(
                      feature.icon,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  title: context.tr(feature.titleKey),
                  trailing: feature.routePath != null ? const CupertinoListTileChevron() : null,
                  onTap: feature.routePath == null ? null : () => navigator.navigateTo(path: feature.routePath!),
                ),
              ),
            ),
            if (!isProUser) const SubscribeButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<_ProFeatureItem> _buildFeatures() {
    final items = <_ProFeatureItem>[
      const _ProFeatureItem(
        titleKey: 'onboarding.app_features.features.data_management.title',
        descriptionKey: 'onboarding.app_features.features.data_management.description',
        icon: CupertinoIcons.doc_text_fill,
        color: Colors.deepPurpleAccent,
        routePath: KRoute.dataManagement,
      ),
      const _ProFeatureItem(
        titleKey: 'onboarding.app_features.features.habit_archive.title',
        descriptionKey: 'onboarding.app_features.features.habit_archive.description',
        icon: CupertinoIcons.archivebox_fill,
        color: CupertinoColors.systemIndigo,
        routePath: KRoute.archivedHabits,
      ),
      const _ProFeatureItem(
        titleKey: 'onboarding.app_features.features.cloud_sync.title',
        descriptionKey: 'onboarding.app_features.features.cloud_sync.description',
        icon: CupertinoIcons.cloud_fill,
        color: CupertinoColors.systemBlue,
      ),
      const _ProFeatureItem(
        titleKey: 'onboarding.app_features.features.share_habits.title',
        descriptionKey: 'onboarding.app_features.features.share_habits.description',
        icon: CupertinoIcons.share,
        color: CupertinoColors.systemTeal,
      ),
      const _ProFeatureItem(
        titleKey: 'onboarding.app_features.features.habit_probability.title',
        descriptionKey: 'onboarding.app_features.features.habit_probability.description',
        icon: CupertinoIcons.chart_bar_square,
        color: CupertinoColors.systemGreen,
      ),
    ];

    if (!appIsAndroid) {
      items.add(
        const _ProFeatureItem(
          titleKey: 'onboarding.app_features.features.home_widget.title',
          descriptionKey: 'onboarding.app_features.features.home_widget.description',
          icon: CupertinoIcons.square_grid_2x2_fill,
          color: CupertinoColors.activeOrange,
        ),
      );
    }

    return items;
  }
}

class _ProFeatureItem {
  const _ProFeatureItem({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
    this.routePath,
  });

  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;
  final String? routePath;
}
