class PickerExtendState {
  final bool isExtended;
  final String? error;

  const PickerExtendState({
    this.isExtended = false,
    this.error,
  });

  PickerExtendState copyWith({
    bool? isExtended,
    String? error,
  }) {
    return PickerExtendState(
      isExtended: isExtended ?? this.isExtended,
      error: error,
    );
  }
}
