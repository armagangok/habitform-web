// import '/core/core.dart';
// import '/services/user_defaults/user_defaults_service.dart';
// import '../enum/user_goal_enum.dart';

// part 'onboarding_event.dart';
// part 'onboarding_state.dart';

// class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
//   final TextEditingController nameTextController = TextEditingController();
//   final List<UserGoal> selectedGoals = [];

//   final UserDefaultsService userDefaultsService;

//   OnboardingBloc({
//     required this.userDefaultsService,
//   }) : super(OnboardingInitial()) {
//     on<NameChangedEvent>(_onChangeName);
//     on<SelectGoalEvent>(_onSelectGoal);
//     on<OnboardingInitialEvent>(_setToInitial);
//     // on<GetHabitRiseProEvent>(_openPaywallEvent);
//   }

//   void _onSelectGoal(SelectGoalEvent event, Emitter<OnboardingState> emit) {
//     if (event.goals.isEmpty) {
//       emit(GoalInvalid());
//     } else {
//       selectedGoals.clear();
//       selectedGoals.addAll(event.goals);
//       emit(GoalValid());
//     }
//   }

//   void _onChangeName(NameChangedEvent event, Emitter<OnboardingState> emit) {
//     if (nameTextController.text.length > 1) {
//       emit(NameValid());
//     } else {
//       emit(NameInvalid());
//     }
//   }

//   void _setToInitial(OnboardingInitialEvent event, Emitter<OnboardingState> emit) {
//     emit(OnboardingInitial());
//   }
// }
