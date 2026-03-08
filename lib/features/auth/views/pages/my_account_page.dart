import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/account_danger_zone_section.dart';
import '../../widgets/account_linked_accounts_section.dart';
import '../../widgets/account_privacy_section.dart';
import '../../widgets/account_profile_section.dart';
import '../../widgets/account_security_section.dart';
import '../../widgets/auth_header_widget.dart';

class MyAccountPage extends ConsumerWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: context.tr(LocaleKeys.settings_settings),
        middle: Text(LocaleKeys.auth_my_account.tr()),
      ),
      child: SafeArea(
        bottom: false,
        child: authState.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (_, __) => Center(
            child: Text(
              LocaleKeys.common_error.tr(),
              style: context.bodyMedium,
            ),
          ),
          data: (user) {
            if (user == null || user.isAnonymous) {
              return ListView(
                padding: EdgeInsets.zero,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: AuthHeaderWidget(),
                  ),
                ],
              );
            }

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 16),
                AccountProfileSection(user: user),
                const SizedBox(height: 24),
                AccountSecuritySection(user: user),
                const SizedBox(height: 24),
                AccountLinkedAccountsSection(user: user),
                const SizedBox(height: 24),
                const AccountPrivacySection(),
                const SizedBox(height: 24),
                AccountDangerZoneSection(user: user),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}
