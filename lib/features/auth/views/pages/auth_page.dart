import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../providers/auth_provider.dart';
import 'forgot_password_page.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  int _segmentedValue = 0; // 0 for Sign In, 1 for Register

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      AppFlushbar.shared.errorFlushbar(LocaleKeys.auth_invalid_email.tr());
      return;
    }
    if (password.length < 6) {
      AppFlushbar.shared.errorFlushbar(LocaleKeys.auth_weak_password.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (_segmentedValue == 0) {
        final cred = await authService.signInWithEmailAndPassword(email, password);
        if (cred.user != null && !cred.user!.emailVerified) {
          await authService.sendEmailVerification();
          await authService.signOut();
          AppFlushbar.shared.warningFlushbar(LocaleKeys.auth_verify_email_sent.tr());
          setState(() => _isLoading = false);
          return;
        }
      } else {
        if (authService.currentUser?.isAnonymous == true) {
          await authService.linkWithEmailAndPassword(email, password);
        } else {
          await authService.createUserWithEmailAndPassword(email, password);
        }
      }
      if (mounted) Navigator.of(context).pop();

      if (_segmentedValue == 1) {
        AppFlushbar.shared.successFlushbar(LocaleKeys.auth_verify_email_sent.tr());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithGoogle();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppFlushbar.shared.errorFlushbar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signInWithApple();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) AppFlushbar.shared.errorFlushbar(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: context.hideKeyboard,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: context.tr(LocaleKeys.settings_settings),
          middle: Text(LocaleKeys.auth_welcome.tr()),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _segmentedValue,
                  onValueChanged: (int? value) {
                    if (value != null) setState(() => _segmentedValue = value);
                  },
                  children: {
                    0: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(LocaleKeys.auth_sign_in.tr()),
                    ),
                    1: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(LocaleKeys.auth_register.tr()),
                    ),
                  },
                ),
              ),
              const SizedBox(height: 24),
              CupertinoListSection.insetGrouped(
                header: Text(LocaleKeys.auth_email.tr()),
                children: [
                  CupertinoTextField(
                    controller: _emailController,
                    placeholder: 'user@example.com',
                    keyboardType: TextInputType.emailAddress,
                    decoration: null,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    style: context.bodyLarge,
                  ),
                ],
              ),
              CupertinoListSection.insetGrouped(
                header: Text(LocaleKeys.auth_password.tr()),
                children: [
                  CupertinoTextField(
                    controller: _passwordController,
                    placeholder: '••••••••',
                    obscureText: true,
                    decoration: null,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    style: context.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : CustomButton(
                        onPressed: _submit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: context.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _segmentedValue == 0 ? LocaleKeys.auth_sign_in.tr() : LocaleKeys.auth_register.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
              ),
              if (_segmentedValue == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: CupertinoButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => const ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      LocaleKeys.auth_forgot_password.tr(),
                      style: TextStyle(
                        color: context.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        LocaleKeys.auth_or.tr(),
                        style: context.bodySmall.copyWith(
                          color: CupertinoColors.secondaryLabel.resolveFrom(context),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    leading: CupertinoCard(
                      color: CupertinoColors.systemOrange,
                      borderRadius: BorderRadius.circular(5),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        FontAwesomeIcons.google,
                        color: Colors.white.withValues(alpha: .9),
                      ),
                    ),
                    title: Text(LocaleKeys.auth_continue_with_google.tr()),
                    onTap: _isLoading ? null : _signInWithGoogle,
                    trailing: const CupertinoListTileChevron(),
                  ),
                  CupertinoListTile(
                    leading: CupertinoCard(
                      color: CupertinoColors.black,
                      borderRadius: BorderRadius.circular(5),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        FontAwesomeIcons.apple,
                        color: Colors.white.withValues(alpha: .9),
                      ),
                    ),
                    title: Text(LocaleKeys.auth_continue_with_apple.tr()),
                    onTap: _isLoading ? null : _signInWithApple,
                    trailing: const CupertinoListTileChevron(),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
