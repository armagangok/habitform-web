/// Represents the state of an account management action.
enum AccountActionStatus {
  idle,
  loading,
  success,
  error,
}

/// State for account-related actions (update profile, change email, etc.).
class AccountActionState {
  const AccountActionState({
    this.status = AccountActionStatus.idle,
    this.errorMessage,
  });

  final AccountActionStatus status;
  final String? errorMessage;

  AccountActionState copyWith({
    AccountActionStatus? status,
    String? errorMessage,
  }) {
    return AccountActionState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  bool get isIdle => status == AccountActionStatus.idle;
  bool get isLoading => status == AccountActionStatus.loading;
  bool get isSuccess => status == AccountActionStatus.success;
  bool get isError => status == AccountActionStatus.error;
}
