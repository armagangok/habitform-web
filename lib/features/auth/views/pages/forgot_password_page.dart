import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      AppFlushbar.shared.errorFlushbar(LocaleKeys.auth_invalid_email.tr());
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordResetEmail(email);

      if (mounted) {
        Navigator.of(context).pop();
        AppFlushbar.shared.successFlushbar(LocaleKeys.auth_forgot_password_success.tr());
      }
    } catch (e) {
      if (mounted) {
        AppFlushbar.shared.errorFlushbar(LocaleKeys.auth_forgot_password_error.tr());
      }
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
          middle: Text(LocaleKeys.auth_forgot_password_title.tr()),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              Text(
                LocaleKeys.auth_forgot_password_desc.tr(),
                style: context.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CupertinoListSection.insetGrouped(
                margin: EdgeInsets.zero,
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
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : CustomButton(
                      onPressed: _resetPassword,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: context.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          LocaleKeys.auth_forgot_password_button.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
