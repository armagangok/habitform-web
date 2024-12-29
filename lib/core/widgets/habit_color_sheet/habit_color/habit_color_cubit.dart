import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habitrise/core/widgets/habit_color_sheet/habit_color/habit_color_state.dart';

class HabitColorCubit extends Cubit<HabitColorState> {
	HabitColorCubit() : super(HabitColorState(isLoading: true));
	
	Future<void> loadInitialData() async {
		final stableState = state;
		try {
		  emit(state.copyWith(isLoading: true));
	
		  // TODO your code here
	
		  emit(state.copyWith(isLoading: false));
		} catch (error) {
		  emit(state.copyWith(error: error.toString()));
		  emit(stableState.copyWith(isLoading: false));
		}
	}
}
