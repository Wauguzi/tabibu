import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';

void main() {
  group('settleRefresh', () {
    test('completes on the first state that is not loading', () async {
      final states = StreamController<String>();
      var done = false;
      unawaited(
        settleRefresh(states.stream, (s) => s == 'loading').then((_) {
          done = true;
        }),
      );
      states.add('loading');
      await pumpEventQueue();
      expect(done, isFalse);
      states.add('loaded');
      await pumpEventQueue();
      expect(done, isTrue);
      await states.close();
    });

    test('completes when the stream closes first', () async {
      final states = StreamController<String>();
      final settled = settleRefresh(states.stream, (s) => s == 'loading');
      await states.close();
      await expectLater(settled, completes);
    });

    test('completes after the timeout when nothing arrives', () async {
      final states = StreamController<String>();
      await expectLater(
        settleRefresh(
          states.stream,
          (s) => s == 'loading',
          timeout: const Duration(milliseconds: 20),
        ),
        completes,
      );
      await states.close();
    });
  });
}
