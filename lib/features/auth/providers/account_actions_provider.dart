import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../purchase/providers/purchase_provider.dart';
import '../models/account_action_state.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

final accountActionsProvider = StateNotifierProvider<AccountActionsNotifier, AccountActionState>((ref) {
  return AccountActionsNotifier(ref.read(authServiceProvider), ref);
});

class AccountActionsNotifier extends StateNotifier<AccountActionState> {
  AccountActionsNotifier(this._authService, this._ref) : super(const AccountActionState());

  final AuthService _authService;
  final Ref _ref;

  Future<void> updateDisplayName(String displayName) async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.updateDisplayName(displayName);
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateProfilePhoto(XFile file) async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.updateProfilePhoto(file);
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteProfilePhoto() async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.deleteProfilePhoto();
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updateEmail(String newEmail) async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.updateEmail(newEmail);
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> linkEmail(String email, String password) async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.linkWithEmailAndPassword(email, password);
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> linkGoogle() async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.linkWithGoogle();
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> linkApple() async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.linkWithApple();
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.reauthenticateWithEmailPassword(
        _authService.currentUser?.email ?? '',
        currentPassword,
      );
      await _authService.updatePassword(newPassword);
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      await _authService.signOut();
      // Invalidate purchaseProvider to force a fresh state
      _ref.invalidate(purchaseProvider);
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> deleteAccount(String? email, String? password) async {
    state = state.copyWith(status: AccountActionStatus.loading, errorMessage: null);
    try {
      if (email != null && password != null) {
        await _authService.reauthenticateWithEmailPassword(email, password);
      }
      await _authService.deleteAccount();
      state = state.copyWith(status: AccountActionStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AccountActionStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void reset() {
    state = const AccountActionState();
  }
}
