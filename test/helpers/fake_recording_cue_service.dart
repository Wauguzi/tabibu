import 'package:tabibu/core/services/recording_cue_service.dart';

/// Scriptable cue for order assertions in composer and symptom tests.
class FakeRecordingCueService implements RecordingCueService {
  final List<String> calls = <String>[];
  bool throwOnStarted = false;
  bool throwOnFinished = false;
  Duration startedDelay = Duration.zero;

  @override
  Future<void> started() async {
    if (startedDelay > Duration.zero) {
      await Future<void>.delayed(startedDelay);
    }
    calls.add('started');
    if (throwOnStarted) throw StateError('cue started failed');
  }

  @override
  Future<void> finished() async {
    calls.add('finished');
    if (throwOnFinished) throw StateError('cue finished failed');
  }
}
