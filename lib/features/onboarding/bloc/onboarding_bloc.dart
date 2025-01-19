import '/core/core.dart';
import '/services/app_default.dart';
import '/services/user_defaults/user_defaults_service.dart';
import '../enum/user_goal_enum.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final TextEditingController nameTextController = TextEditingController();
  final List<UserGoal> selectedGoals = [];

  final UserDefaultsService userDefaultsService;
  final AppDefaultsService appDefaultsService;

  OnboardingBloc({
    required this.userDefaultsService,
    required this.appDefaultsService,
  }) : super(OnboardingInitial()) {
    on<OnboardingInitialEvent>(_setToInitial);
    // on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<CheckFirstLaunchEvent>(_checkFirstLaunch);
  }

  void _setToInitial(OnboardingInitialEvent event, Emitter<OnboardingState> emit) {
    emit(OnboardingInitial());
  }

  // Future<void> _onCompleteOnboarding(CompleteOnboardingEvent event, Emitter<OnboardingState> emit) async {
  //   try {
  //     // Save user defaults
  //     final userDefaults = UserDefaults(
  //       userName: nameTextController.text,
  //       userGoals: selectedGoals,
  //     );
  //     await userDefaultsService.setUserDefault(userDefaults);

  //     // Update app defaults to indicate app has been opened
  //     final appDefaults = AppDefaults(isAppOpenedFirstTime: true);
  //     await appDefaultsService.saveAppDefaults(appDefaults);

  //     emit(OnboardingCompleted());
  //   } catch (e) {
  //     emit(OnboardingError(e.toString()));
  //   }
  // }

  Future<void> _checkFirstLaunch(CheckFirstLaunchEvent event, Emitter<OnboardingState> emit) async {
    try {
      final appDefaults = await appDefaultsService.gettAppDefault();

      if (appDefaults?.isAppOpenedFirstTime ?? true) {
        emit(OnboardingRequired());
      } else {
        emit(OnboardingSkipped());
      }
    } catch (e) {
      emit(OnboardingError(e.toString()));
    }
  }
}
