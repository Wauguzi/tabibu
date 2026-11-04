import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
import 'package:tabibu/core/services/recording_cue_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The longest message the conversation layer takes.
const mdtMessageMaxLength = 2000;

enum _ComposerVoiceStatus {
  none,
  unsupported,
  permissionDenied,
  permissionPermanent,
  startFailed,
  recordFailed,
  sendFailed,
}

/// Sends once for text (clears the box) and once for a voice note (droppable
/// upstream). Recording blocks a second voice send until the preview is
/// discarded or the note lands.
class MdtComposer extends StatefulWidget {
  const MdtComposer({
    required this.hint,
    required this.sendLabel,
    required this.onSend,
    this.onVoiceSend,
    this.recorder,
    this.player,
    this.cues,
    this.analytics,
    this.voiceSurface = 'mdt',
    this.voiceEnabled = true,
    super.key,
  });

  final String hint;
  final String sendLabel;
  final ValueChanged<String> onSend;

  /// Returns true when the note was accepted so the preview can clear.
  final Future<bool> Function(RecordedAudio audio)? onVoiceSend;
  final AudioRecorderService? recorder;
  final AudioPlayerService? player;
  final RecordingCueService? cues;
  final AnalyticsService? analytics;

  /// Analytics surface: `'chat'` or `'mdt'` — never audio, ids or paths.
  final String voiceSurface;

  /// When false, hide the mic (closed threads).
  final bool voiceEnabled;

  @override
  State<MdtComposer> createState() => _MdtComposerState();
}

class _MdtComposerState extends State<MdtComposer> {
  final _controller = TextEditingController();
  late final AudioRecorderService _recorder;
  late final AudioPlayerService _player;
  late final RecordingCueService _cues;
  AnalyticsService? _analyticsOrNull;
  StreamSubscription<double>? _levelsSub;
  Timer? _tick;
  RecordedAudio? _preview;
  var _recording = false;
  var _starting = false;
  var _stopping = false;
  var _sendingVoice = false;
  var _seconds = 0;
  var _level = 0.0;
  _ComposerVoiceStatus _status = _ComposerVoiceStatus.none;
  var _previewPlaying = false;
  var _previewLoaded = false;

  static const _maxSeconds = 120;

  @override
  void initState() {
    super.initState();
    _recorder = widget.recorder ?? getIt<AudioRecorderService>();
    _player = widget.player ?? getIt<AudioPlayerService>();
    _cues = widget.cues ?? getIt<RecordingCueService>();
    _analyticsOrNull = widget.analytics;
    _controller.addListener(() => setState(() {}));
  }

  AnalyticsService? get _analytics {
    final cached = _analyticsOrNull;
    if (cached != null) return cached;
    if (widget.analytics != null) return widget.analytics;
    if (getIt.isRegistered<AnalyticsService>()) {
      return _analyticsOrNull = getIt<AnalyticsService>();
    }
    return null;
  }

  @override
  void dispose() {
    _tick?.cancel();
    unawaited(_levelsSub?.cancel());
    // Cancel an open or in-flight start so the mic does not stay hot after
    // the person leaves the thread.
    if (_recording || _starting) unawaited(_recorder.cancel());
    _controller.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
  }

  Future<void> _toggleRecord() async {
    final onVoice = widget.onVoiceSend;
    if (onVoice == null || !widget.voiceEnabled) return;
    if (!_recorder.isSupported) {
      setState(() => _status = .unsupported);
      return;
    }
    if (_sendingVoice) return;
    if (_preview != null) return;
    if (_recording) {
      await _stopRecord();
      return;
    }
    final permission = await _recorder.ensurePermission();
    if (!mounted) return;
    if (permission == .permanentlyDenied) {
      setState(() => _status = .permissionPermanent);
      return;
    }
    if (permission != .granted) {
      setState(() => _status = .permissionDenied);
      return;
    }
    _starting = true;
    try {
      await _cues.started();
    } on Object catch (_) {
      // Cue is best-effort; recording still opens.
    }
    if (!mounted) {
      _starting = false;
      unawaited(_recorder.cancel());
      return;
    }
    try {
      await _recorder.start();
    } on Object catch (_) {
      _starting = false;
      if (!mounted) {
        unawaited(_recorder.cancel());
        return;
      }
      setState(() => _status = .startFailed);
      return;
    }
    _starting = false;
    if (!mounted) {
      unawaited(_recorder.cancel());
      return;
    }
    setState(() {
      _recording = true;
      _seconds = 0;
      _status = .none;
      _preview = null;
    });
    unawaited(
      _analytics?.logVoiceRecordingStarted(surface: widget.voiceSurface),
    );
    _levelsSub = _recorder.levels.listen((level) {
      if (mounted) setState(() => _level = level);
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted) return;
      setState(() => _seconds += 1);
      if (_seconds >= _maxSeconds) await _stopRecord();
    });
  }

  Future<void> _stopRecord() async {
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
      _preview = clip;
      if (clip == null) {
        _status = .recordFailed;
      }
    });
    _stopping = false;
  }

  Future<void> _cancelPreview() async {
    await _recorder.cancel();
    unawaited(
      _analytics?.logVoiceRecordingDiscarded(surface: widget.voiceSurface),
    );
    setState(() {
      _preview = null;
      _previewPlaying = false;
      _previewLoaded = false;
      _status = .none;
    });
  }

  static const _previewPlayerId = 'composer-preview';

  Future<void> _playPreview() async {
    final clip = _preview;
    if (clip == null) return;
    if (_previewPlaying) {
      await _player.pause();
      unawaited(_analytics?.logVoicePlaybackPaused());
      setState(() => _previewPlaying = false);
      return;
    }
    // Only resume when the shared player still holds this preview; a bubble
    // (or cue) that took the player in between must reload the bytes.
    var resumed = false;
    if (_previewLoaded) {
      resumed = await _player.resume(_previewPlayerId);
    }
    if (!resumed) {
      await _player.playBytes(clip.bytes, id: _previewPlayerId);
      _previewLoaded = true;
    }
    unawaited(_analytics?.logVoicePlaybackStarted());
    if (mounted) setState(() => _previewPlaying = true);
  }

  Future<void> _sendVoice() async {
    final clip = _preview;
    final onVoice = widget.onVoiceSend;
    if (clip == null || onVoice == null || _sendingVoice) return;
    setState(() => _sendingVoice = true);
    final ok = await onVoice(clip);
    if (!mounted) return;
    setState(() {
      _sendingVoice = false;
      if (ok) {
        _preview = null;
        _previewPlaying = false;
        _previewLoaded = false;
        _status = .none;
      } else {
        _status = .sendFailed;
      }
    });
  }

  String _statusText(AppLocalizations l10n) => switch (_status) {
    .none => '',
    .unsupported => l10n.chatVoiceUnsupported,
    .permissionDenied => l10n.chatVoicePermissionDenied,
    .permissionPermanent => l10n.chatVoicePermissionPermanent,
    .startFailed => l10n.chatVoiceStartFailed,
    .recordFailed => l10n.chatVoiceRecordFailed,
    .sendFailed => l10n.chatVoiceSendFailed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasText = _controller.text.trim().isNotEmpty;
    final showMic =
        widget.voiceEnabled &&
        widget.onVoiceSend != null &&
        _recorder.isSupported;
    final permanent = _status == .permissionPermanent;
    final statusText = _statusText(l10n);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.xs,
          AppSpacing.screenMargin,
          AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            if (_preview != null) ...[
              _PreviewBar(
                durationMs: _preview!.durationMs,
                playing: _previewPlaying,
                sending: _sendingVoice,
                onPlay: _playPreview,
                onDiscard: _cancelPreview,
                onSend: _sendVoice,
              ),
              const SizedBox(height: AppSpacing.xs),
            ] else if (_recording) ...[
              Row(
                children: [
                  CircleIconButton(
                    icon: Assets.icons.cancelIcon,
                    onTap: _toggleRecord,
                    semanticLabel: l10n.chatVoiceStopLabel,
                    filled: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        Text(
                          l10n.chatVoiceRecording(_seconds),
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
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  TabibuButton.secondary(
                    label: l10n.chatVoiceCancelLabel,
                    onTap: () async {
                      await _recorder.cancel();
                      _tick?.cancel();
                      await _levelsSub?.cancel();
                      if (!mounted) return;
                      setState(() {
                        _recording = false;
                        _level = 0;
                        _status = .none;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            if (!_recorder.isSupported && widget.voiceEnabled) ...[
              Text(
                l10n.chatVoiceUnsupported,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            Row(
              crossAxisAlignment: .end,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: mdtMessageMaxLength,
                      enabled: !_recording,
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      keyboardType: TextInputType.multiline,
                      textCapitalization: .sentences,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(mdtMessageMaxLength),
                      ],
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                ),
                if (showMic && _preview == null && !_recording) ...[
                  const SizedBox(width: AppSpacing.xs),
                  CircleIconButton(
                    icon: Assets.icons.microphoneIcon,
                    semanticLabel: l10n.chatVoiceRecordLabel,
                    onTap: _sendingVoice ? null : _toggleRecord,
                  ),
                ],
                const SizedBox(width: AppSpacing.xs),
                CircleIconButton(
                  icon: Assets.icons.sendOutlineIcon,
                  semanticLabel: widget.sendLabel,
                  filled: true,
                  onTap: hasText && !_recording ? _sendText : null,
                ),
              ],
            ),
            if (statusText.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                statusText,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (permanent) ...[
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: .centerLeft,
                  child: TabibuButton.secondary(
                    label: l10n.chatVoiceOpenSettings,
                    onTap: openAppSettings,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _PreviewBar extends StatelessWidget {
  const _PreviewBar({
    required this.durationMs,
    required this.playing,
    required this.sending,
    required this.onPlay,
    required this.onDiscard,
    required this.onSend,
  });

  final int durationMs;
  final bool playing;
  final bool sending;
  final VoidCallback onPlay;
  final VoidCallback onDiscard;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final seconds = (durationMs / 1000).ceil();
    return Row(
      children: [
        CircleIconButton(
          icon: playing ? Assets.icons.pauseIcon : Assets.icons.playIcon,
          onTap: sending ? null : onPlay,
          semanticLabel: playing
              ? l10n.chatVoicePauseLabel
              : l10n.chatVoicePlayLabel,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            l10n.chatVoicePreview(seconds),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        TabibuButton.secondary(
          label: l10n.chatVoiceDiscardLabel,
          onTap: sending ? null : onDiscard,
        ),
        const SizedBox(width: AppSpacing.xs),
        TabibuButton.primary(
          label: l10n.chatVoiceSendLabel,
          onTap: sending ? null : onSend,
          isLoading: sending,
        ),
      ],
    );
  }
}
