import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final TextEditingController nameTextController = TextEditingController();
  final List<int> selectedGoals = [];
  final List<String> goalList = [
    "Better productivity",
    "Build a routine",
    "Break bad habits",
    "Get healthier",
    "Time management",
    "Reduce stress",
    "Other",
  ];

  OnboardingBloc() : super(OnboardingInitial()) {
    on<NameChangedEvent>(_onChangeName);
    on<SelectGoalEvent>(_onSelectGoal);
    on<OnboardingInitialEvent>(_setToInitial);
  }

  void _onSelectGoal(SelectGoalEvent event, Emitter<OnboardingState> emit) {
    if (event.goals.isEmpty) {
      emit(GoalInvalid());
    } else {
      selectedGoals.clear();
      selectedGoals.addAll(event.goals);
      emit(GoalValid());
    }
  }

  void _onChangeName(NameChangedEvent event, Emitter<OnboardingState> emit) {
    if (nameTextController.text.length > 1) {
      emit(NameValid());
    } else {
      emit(NameInvalid());
    }
  }

  void _setToInitial(OnboardingInitialEvent event, Emitter<OnboardingState> emit) {
    emit(OnboardingInitial());
  }
}
