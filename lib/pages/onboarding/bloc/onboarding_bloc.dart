import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final TextEditingController nameTextController = TextEditingController();
  OnboardingBloc() : super(OnboardingInitial()) {
    on<NameChangedEvent>(onChangeName);
    on<SelectGoalEvent>(onSelectGoal);
    on<OnboardingInitialEvent>(setToInitial);
  }

  final goalList = [
    "Better productivity",
    "Build a routine",
    "Break bad habits",
    "Get healthier",
    "Time management",
    "Reduce stress",
    "Other",
  ];

  List<int> selectedGoals = [];

  void onSelectGoal(SelectGoalEvent event, Emitter<OnboardingState> emit) {
    if (event.goals.isEmpty) {
      emit(GoalInvalid());
    } else {
      selectedGoals = event.goals;
      emit(GoalValid());
    }
  }

  void onChangeName(NameChangedEvent event, Emitter<OnboardingState> emit) {
    if (nameTextController.text.length > 1) {
      emit(NameValid());
    } else {
      emit(NameInvalid());
    }
  }

  void setToInitial(OnboardingInitialEvent event, Emitter<OnboardingState> emit) {
    emit(OnboardingInitial());
  }
}
