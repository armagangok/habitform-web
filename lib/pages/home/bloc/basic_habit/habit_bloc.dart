import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '/models/habit_model.dart';
import '/services/habit_service.dart';

part 'habit_event.dart';
part 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final habitService = HabitService();

  HabitBloc() : super(HabitInitial()) {
    on<FetchHabitsEvent>(_onFetchHabits);
    on<IdleHabitEvent>(_idle);
    on<SaveHabitsEvent>(_saveHabit);
  }

  Future<void> _onFetchHabits(FetchHabitsEvent event, Emitter<HabitState> emit) async {
    try {
      emit(HabitsLoading()); // Yükleniyor durumuna geç
      final response = await habitService.fetchHabits(); // Servisten alışkanlıkları al
      emit(HabitsFetched(response)); // Başarılı durumda, alınan alışkanlıkları ilet
    } on PlatformException catch (e, s) {
      debugPrint(s.toString());
      emit(HabitsFetchError(e.message ?? "An error occurred while fetching habits"));
    }
  }

  Future<void> _idle(IdleHabitEvent event, Emitter<HabitState> emit) async {}

  Future<void> _saveHabit(SaveHabitsEvent event, Emitter<HabitState> emit) async {}
}
