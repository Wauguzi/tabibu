import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
import 'package:tabibu/core/services/recording_cue_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_bloc.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_event.dart';
import 'package:tabibu/features/appointments/blocs/appointments_bloc/appointments_state.dart';
import 'package:tabibu/features/reports/presentation/widgets/settled_sheet.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Mic, level meter and transcribe controls beside the booking symptoms field.
///
/// Caps a take at 45 s as WAV 16 kHz (symptoms, not chat). Voice recognition is
/// English only; typing always stays available in both languages.
class SymptomVoiceControls extends StatefulWidget {
  const SymptomVoiceControls({
    required this.patientUid,
    required this.symptoms,
    required this.onTranscriptionUid,
    required this.showAiNotice,
    this.recorder,
    this.cues,
    this.preferences,
    this.offline = false,
    this.initialClip,
    this.maxSeconds = defaultMaxSeconds,
    super.key,
  });

  final String patientUid;
  final TextEditingController symptoms;
  final ValueChanged<String?> onTranscriptionUid;
  final ValueChanged<bool> showAiNotice;
  final AudioRecorderService? recorder;
  final RecordingCueService? cues;
  final Future<SharedPreferences> Function()? preferences;
  final bool offline;

  /// Test hook: a finished clip ready to Transcribe without recording.
  final RecordedAudio? initialClip;

  /// Cap for a symptoms take; tests may lower it to fire the auto-stop.
  final int maxSeconds;

  static const defaultMaxSeconds = 45;
  static const symptomsMaxLength = 500;
  static const consentKey = 'symptom_voice_consent_v1';
  static const AudioFormat recordFormat = .wav16k;

  @override
  State<SymptomVoiceControls> createState() => _SymptomVoiceControlsState();
}

class _SymptomVoiceControlsState extends State<SymptomVoiceControls> {
  late final AudioRecorderService _recorder;
  late final RecordingCueService _cues;
  StreamSubscription<double>? _levelsSub;
  Timer? _tick;
  RecordedAudio? _pending;
  var _recording = false;
  var _stopping = false;
  var _seconds = 0;
  var _level = 0.0;
  var _status = '';
  var _consentShown = false;

  @override
  void initState() {
    super.initState();
    _recorder = widget.recorder ?? getIt<AudioRecorderService>();
    _cues = widget.cues ?? getIt<RecordingCueService>();
    _pending = widget.initialClip;
  }

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_levelsSub?.cancel());
    if (_recording) unawaited(_recorder.cancel());
    super.dispose();
  }

  Future<bool> _ensureConsent() async {
    if (_consentShown) return true;
    final prefs = await (widget.preferences ?? SharedPreferences.getInstance)();
    if (prefs.getBool(SymptomVoiceControls.consentKey) ?? false) {
      _consentShown = true;
      return true;
    }
    if (!mounted) return false;
    final l10n = context.l10n;
    final accepted = await showSettledSheet<bool>(
      context,
      title: l10n.symptomVoiceConsentTitle,
      subtitle: l10n.symptomVoiceConsentBody,
      cancelLabel: l10n.commonCancel,
      builder: (sheet) => TabibuButton.primary(
        label: l10n.symptomVoiceConsentContinue,
        onTap: () => Navigator.of(sheet).pop(true),
      ),
    );
    if (accepted != true) return false;
    await prefs.setBool(SymptomVoiceControls.consentKey, true);
    _consentShown = true;
    return true;
  }

  Future<void> _toggleRecord() async {
    final l10n = context.l10n;
    if (!_recorder.isSupported) {
      setState(() => _status = l10n.symptomVoiceUnsupported);
      return;
    }
    if (_recording) {
      await _stop();
      return;
    }
    if (!await _ensureConsent()) return;

    final permission = await _recorder.ensurePermission();
    if (!mounted) return;
    if (permission != .granted) {
      setState(() => _status = l10n.symptomVoicePermissionDenied);
      return;
    }

    try {
      await _cues.started();
    } on Object catch (_) {
      // Cue is best-effort; recording still opens.
    }
    try {
      await _recorder.start(format: SymptomVoiceControls.recordFormat);
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _status = l10n.symptomVoiceStartFailed);
      return;
    }
    if (!mounted) return;
    setState(() {
      _recording = true;
      _seconds = 0;
      _pending = null;
      _status = '';
      widget.onTranscriptionUid(null);
      widget.showAiNotice(false);
    });
    _levelsSub = _recorder.levels.listen((level) {
      if (mounted) setState(() => _level = level);
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      setState(() => _seconds += 1);
      if (_seconds >= widget.maxSeconds) {
        await _stop();
      }
    });
  }

  Future<void> _stop() async {
    if (_stopping) return;
    _stopping = true;
    _tick?.cancel();
    _tick = null;
    final levels = _levelsSub;
    _levelsSub = null;
    unawaited(levels?.cancel());
    final clip = await _recorder.stop();
    try {
      await _cues.finished();
    } on Object catch (_) {
      // Cue is best-effort.
    }
    if (!mounted) {
      _stopping = false;
      return;
    }
    setState(() {
      _recording = false;
      _level = 0;
      _pending = clip;
      if (clip == null) {
        _status = context.l10n.symptomVoiceFailed;
      }
    });
    _stopping = false;
  }

  void _transcribe() {
    final clip = _pending;
    if (clip == null || widget.offline) {
      if (widget.offline) {
        setState(() => _status = context.l10n.symptomVoiceOffline);
      }
      return;
    }
    context.read<AppointmentsBloc>().add(
      SymptomsTranscribeRequested(uid: widget.patientUid, audio: clip),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final transcribing =
        context.watch<AppointmentsBloc>().state is SymptomsTranscribeInProgress;

    if (!_recorder.isSupported) {
      return Text(
        l10n.symptomVoiceUnsupported,
        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    return BlocListener<AppointmentsBloc, AppointmentsState>(
      listenWhen: (previous, current) =>
          current is SymptomsTranscribeSuccess ||
          current is SymptomsTranscribeFailure,
      listener: (context, state) {
        switch (state) {
          case SymptomsTranscribeSuccess(
            :final transcript,
            :final transcriptionUid,
          ):
            final existing = widget.symptoms.text.trim();
            final combined = existing.isEmpty
                ? transcript
                : '$existing\n$transcript';
            const limit = SymptomVoiceControls.symptomsMaxLength;
            final cut = combined.length > limit;
            widget.symptoms.text = cut
                ? combined.substring(0, limit)
                : combined;
            widget.onTranscriptionUid(transcriptionUid);
            widget.showAiNotice(true);
            setState(() {
              _pending = null;
              _status = cut
                  ? l10n.pasteCutAtLimit(limit)
                  : l10n.symptomVoiceDeletedNotice;
            });
          case SymptomsTranscribeFailure(:final error):
            setState(() {
              _status = error == AppError.noInternet
                  ? l10n.symptomVoiceOffline
                  : l10n.symptomVoiceFailed;
            });
          default:
            break;
        }
      },
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              CircleIconButton(
                icon: _recording
                    ? Assets.icons.cancelIcon
                    : Assets.icons.microphoneIcon,
                onTap: _toggleRecord,
                semanticLabel: _recording
                    ? l10n.symptomVoiceStopLabel
                    : l10n.symptomVoiceRecordLabel,
                filled: _recording,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _recording
                    ? Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          Text(
                            l10n.symptomVoiceRecording(_seconds),
                            style: textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            child: LinearProgressIndicator(
                              value: _level.clamp(0.05, 1.0),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      )
                    : TabibuButton.secondary(
                        label: l10n.symptomVoiceTranscribeLabel,
                        onTap: _pending == null || widget.offline
                            ? null
                            : _transcribe,
                        isLoading: transcribing,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.symptomVoiceEnglishOnly,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _status,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
