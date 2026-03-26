import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';
import '../../../core/widgets/custom_list_tile.dart';
import '../../purchase/providers/purchase_provider.dart';

class ProFeaturesSection extends ConsumerWidget {
  const ProFeaturesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CustomSection(
        footer: Text(context.tr(LocaleKeys.settings_pro_features_subtitle)),
        child: Column(
          children: [
            CustomListTile(
              title: context.tr(LocaleKeys.settings_pro_features_title),
              onTap: () => navigator.navigateTo(path: KRoute.proFeatures),
              trailing: const CupertinoListTileChevron(),
              additionalInfo: Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Habit',
                          style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Form',
                          style: context.titleMedium.copyWith(fontWeight: FontWeight.bold, color: context.primary),
                        ),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 0,
                    color: context.primary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      child: Center(
                        child: Text(
                          'PRO',
                          style: context.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomListTile(
              leading: CupertinoCard(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5),
                padding: const EdgeInsets.all(2),
                child: Icon(
                  CupertinoIcons.doc_person_fill,
                  color: Colors.white.withValues(alpha: .9),
                ),
              ),
              title: context.tr(LocaleKeys.settings_rc_id),
              onTap: () => ref.read(purchaseProvider.notifier).copyCustomerId(),
              trailing: const Icon(
                CupertinoIcons.doc_on_clipboard_fill,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
