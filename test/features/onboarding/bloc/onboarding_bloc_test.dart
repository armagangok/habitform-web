import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitrise/features/onboarding/bloc/onboarding_bloc.dart';
import 'package:habitrise/features/onboarding/enum/user_goal_enum.dart';
import 'package:habitrise/services/user_defaults/user_defaults_service.dart';

void main() {
  group('OnboardingBloc', () {
    late OnboardingBloc onboardingBloc;

    setUp(() {
      onboardingBloc = OnboardingBloc(userDefaultsService: UserDefaultsService());
    });

    tearDown(() {
      onboardingBloc.close();
    });

    test('initial state is OnboardingInitial', () {
      expect(onboardingBloc.state, isA<OnboardingInitial>());
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'emits [NameValid] when NameChangedEvent is added with valid name',
      build: () => onboardingBloc,
      act: (bloc) {
        bloc.nameTextController.text = 'Valid Name';
        bloc.add(NameChangedEvent('Valid Name'));
      },
      expect: () => [isA<NameValid>()],
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'emits [GoalValid] when SelectGoalEvent is added with non-empty goals',
      build: () => onboardingBloc,
      act: (bloc) => bloc.add(SelectGoalEvent(
        goals: [
          UserGoal.breakBadHabits,
          UserGoal.reduceStress,
        ],
      )),
      expect: () => [isA<GoalValid>()],
    );
  });
}
