import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'onboarding_final_event.dart';
part 'onboarding_final_state.dart';

class OnboardingFinalBloc extends Bloc<OnboardingFinalEvent, OnboardingFinalState> {
  OnboardingFinalBloc() : super(OnboardingFinalInitial()) {
    on<OnboardingFinalEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
