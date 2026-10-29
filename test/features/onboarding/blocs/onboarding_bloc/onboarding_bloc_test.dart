import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/hive_helper.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_bloc.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_event.dart';
import 'package:tabibu/features/onboarding/blocs/onboarding_bloc/onboarding_state.dart';

class MockHiveHelper extends Mock implements HiveHelper {}

void main() {
  group('OnboardingBloc', () {
    late MockHiveHelper hiveHelper;

    setUp(() {
      hiveHelper = MockHiveHelper();
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'caches onboarding done on completion',
      build: () {
        when(
          () => hiveHelper.cacheOnboarding(isOnboarded: true),
        ).thenAnswer((_) async {});
        return OnboardingBloc(hiveHelper: hiveHelper);
      },
      act: (bloc) => bloc.add(const OnboardingCompleted()),
      expect: () => const [OnboardingInProgress(), OnboardingComplete()],
      verify: (_) {
        verify(() => hiveHelper.cacheOnboarding(isOnboarded: true)).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'maps a cache failure to unknown',
      build: () {
        when(
          () => hiveHelper.cacheOnboarding(
            isOnboarded: any(named: 'isOnboarded'),
          ),
        ).thenThrow(Exception('disk full'));
        return OnboardingBloc(hiveHelper: hiveHelper);
      },
      act: (bloc) => bloc.add(const OnboardingCompleted()),
      expect: () => const [
        OnboardingInProgress(),
        OnboardingFailure(error: AppError.unknown),
      ],
    );
  });
}
