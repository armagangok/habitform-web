class HabitColorState {
	final bool isLoading;
	final String? error;
	  
	const HabitColorState({
		this.isLoading = false,
		this.error,
	});
	  
	HabitColorState copyWith({
		bool? isLoading,
		String? error,
	}) {
		return HabitColorState(
			isLoading: isLoading ?? this.isLoading,
			error: error ?? this.error,
		);
	}
}
