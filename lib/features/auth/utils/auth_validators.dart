/// Central validators for auth-related forms.
class AuthValidators {
  AuthValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!value.contains('@') || !value.contains('.')) {
      return 'auth.invalid_email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 6) return 'auth.weak_password';
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'auth.confirm_password_required';
    if (value != password) return 'auth.password_mismatch';
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) return 'auth.display_name_required';
    return null;
  }
}
