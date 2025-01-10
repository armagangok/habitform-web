import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '/models/chained_habit/chained_habit_model.dart';
import '/services/chained_habit/mock_chained_habit_service.dart';

part 'chain_habit_event.dart';
part 'chain_habit_state.dart';

class ChainHabitBloc extends Bloc<ChainHabitEvent, ChainHabitState> {
  ChainHabitBloc({required this.habitService}) : super(ChainHabitInitial()) {
    on<FetchChainedHabitEvent>(_onFetchChainedHabits);
  }
  final MockChainedHabitService habitService;

  Future<void> _onFetchChainedHabits(FetchChainedHabitEvent event, Emitter<ChainHabitState> emit) async {
    try {
      emit(ChainHabitsLoading()); // Yükleniyor durumuna geç
      final response = await habitService.fetchChainedHabits(); // Servisten alışkanlıkları al
      emit(ChainHabitsFetched(response)); // Başarılı durumda, alınan alışkanlıkları ilet
    } on PlatformException catch (e, s) {
      debugPrint(s.toString());
      emit(ChainHabitsFetchError(e.message ?? "An error occurred while fetching habits"));
    }
  }
}
