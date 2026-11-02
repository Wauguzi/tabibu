import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_bloc.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_event.dart';
import 'package:tabibu/features/alerts/blocs/public_alerts_bloc/public_alerts_state.dart';

void main() {
  group('PublicAlertsBloc', () {
    test('starts empty', () {
      expect(PublicAlertsBloc().state, const PublicAlertsInitial());
    });

    blocTest<PublicAlertsBloc, PublicAlertsState>(
      'drops its data on reset',
      build: PublicAlertsBloc.new,
      seed: () => const PublicAlertsLoadSuccess(offline: true),
      act: (bloc) => bloc.add(const PublicAlertsReset()),
      expect: () => [const PublicAlertsInitial()],
    );
  });
}
