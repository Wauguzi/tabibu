import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/analytics_service.dart';
import 'package:tabibu/core/services/audio_service_contract.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/conversations/data/models/message_model.dart';
import 'package:tabibu/features/conversations/presentation/widgets/voice_note_wave.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Play/pause + designer wave for one voice note. Fetches bytes on tap only.
///
/// The player has no seek API, so the wave is not interactive (report that).
class VoiceNotePlayer extends StatefulWidget {
  const VoiceNotePlayer({
    required this.message,
    required this.foreground,
    required this.loadBytes,
    this.player,
    this.analytics,
    super.key,
  });

  final MessageModel message;
  final Color foreground;
  final Future<Uint8List> Function(MessageModel message) loadBytes;
  final AudioPlayerService? player;
  final AnalyticsService? analytics;

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer>
    with SingleTickerProviderStateMixin {
  late final AudioPlayerService _player;
  AnalyticsService? _analyticsOrNull;
  StreamSubscription<AudioPlayback>? _sub;
  AnimationController? _fill;
  var _playing = false;
  var _active = false;
  double _fraction = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  var _loading = false;
  var _error = false;
  Uint8List? _cachedBytes;
  Timer? _resetHold;
  Timer? _announceTick;
  var _lastAnnouncedSec = -1;
  var _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = widget.player ?? getIt<AudioPlayerService>();
    _analyticsOrNull = widget.analytics;
    _duration = Duration(milliseconds: widget.message.voiceDurationMs);
    _sub = _player.playback.listen(_onPlayback);
    _fill =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 120),
        )..addListener(() {
          if (mounted) setState(() => _fraction = _fill!.value);
        });
  }

  @override
  void didUpdateWidget(covariant VoiceNotePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.uid == widget.message.uid) return;
    // Element reuse with a new message: drop the previous clip's cache.
    _cachedBytes = null;
    _playing = false;
    _active = false;
    _wasPlaying = false;
    _error = false;
    _loading = false;
    _position = Duration.zero;
    _duration = Duration(milliseconds: widget.message.voiceDurationMs);
    _lastAnnouncedSec = -1;
    _resetHold?.cancel();
    _announceTick?.cancel();
    _setFraction(0, animate: false);
  }

  @override
  void dispose() {
    _resetHold?.cancel();
    _announceTick?.cancel();
    unawaited(_sub?.cancel());
    _fill?.dispose();
    super.dispose();
  }

  void _onPlayback(AudioPlayback event) {
    if (event.id != widget.message.uid) {
      if (_playing || _active) {
        _playing = false;
        _active = false;
        _announceTick?.cancel();
        _setFraction(0, animate: false);
        setState(() {});
      }
      return;
    }
    _position = event.position;
    if (event.duration > Duration.zero) _duration = event.duration;
    final totalMs = _duration.inMilliseconds;
    final next = totalMs <= 0
        ? 0.0
        : (event.position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    if (event.completed) {
      _playing = false;
      _wasPlaying = false;
      _announceTick?.cancel();
      _announceProgress();
      _setFraction(1, animate: false);
      _resetHold?.cancel();
      _resetHold = Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _active = false;
        _setFraction(0, animate: false);
        setState(() {});
      });
      setState(() {});
      return;
    }
    final paused = _wasPlaying && !event.playing;
    _playing = event.playing;
    _wasPlaying = event.playing;
    if (event.playing) {
      _active = true;
      _ensureAnnounceTick();
    } else {
      _announceTick?.cancel();
      if (paused) _announceProgress();
    }
    final reduce = MediaQuery.disableAnimationsOf(context);
    _setFraction(next, animate: event.playing && !reduce);
    setState(() {});
  }

  void _ensureAnnounceTick() {
    _announceTick?.cancel();
    _announceTick = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || !_playing) return;
      final sec = _position.inSeconds;
      if (sec == _lastAnnouncedSec) return;
      _lastAnnouncedSec = sec;
      _announceProgress();
    });
  }

  void _announceProgress() {
    if (!mounted) return;
    final l10n = context.l10n;
    final direction = Directionality.of(context);
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        l10n.chatVoiceProgress(_format(_position), _format(_duration)),
        direction,
      ),
    );
  }

  void _setFraction(double value, {required bool animate}) {
    final fill = _fill;
    if (fill == null) {
      _fraction = value;
      return;
    }
    if (!animate) {
      fill.value = value;
      _fraction = value;
      return;
    }
    fill.animateTo(value, duration: const Duration(milliseconds: 100));
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

  Future<void> _toggle() async {
    if (_loading) return;
    if (_playing) {
      await _player.pause();
      unawaited(_analytics?.logVoicePlaybackPaused());
      return;
    }
    // Same clip still loaded: keep the playhead. If another bubble or the
    // composer preview took the shared player, resume fails and we reload.
    if (_active && _cachedBytes != null) {
      final resumed = await _player.resume(widget.message.uid);
      if (resumed) {
        unawaited(_analytics?.logVoicePlaybackStarted());
        return;
      }
    }
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final bytes = _cachedBytes ?? await widget.loadBytes(widget.message);
      _cachedBytes = bytes;
      if (!mounted) return;
      await _player.playBytes(bytes, id: widget.message.uid);
      unawaited(_analytics?.logVoicePlaybackStarted());
    } on Object catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _format(Duration d) {
    final total = d.inSeconds.clamp(0, 9999);
    final m = total ~/ 60;
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final idle = !_playing && _fraction == 0;
    final elapsed = idle ? _duration : _position;
    final total = _duration;
    final label = _playing ? l10n.chatVoicePauseLabel : l10n.chatVoicePlayLabel;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Row(
          children: [
            CircleIconButton(
              icon: _playing ? Assets.icons.pauseIcon : Assets.icons.playIcon,
              onTap: _toggle,
              semanticLabel: label,
              onCard: true,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) => ExcludeSemantics(
                  child: VoiceNoteWave(
                    peaks: widget.message.voicePeaks,
                    foreground: widget.foreground,
                    playedFraction: _fraction,
                    active: _active,
                    width: constraints.maxWidth,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Semantics(
                liveRegion: false,
                label: l10n.chatVoiceProgress(
                  _format(_position),
                  _format(total),
                ),
                child: FittedBox(
                  fit: .scaleDown,
                  alignment: .centerLeft,
                  child: Text(
                    '${_format(elapsed)} / ${_format(total)}',
                    maxLines: 1,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: widget.foreground.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_error) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.chatVoicePlayFailed,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: widget.foreground.withValues(alpha: 0.85),
            ),
          ),
        ],
        _TranscriptLine(message: widget.message, foreground: widget.foreground),
      ],
    );
  }
}

class _TranscriptLine extends StatefulWidget {
  const _TranscriptLine({required this.message, required this.foreground});

  final MessageModel message;
  final Color foreground;

  @override
  State<_TranscriptLine> createState() => _TranscriptLineState();
}

class _TranscriptLineState extends State<_TranscriptLine> {
  Timer? _queuedHold;
  var _showUnavailable = false;

  @override
  void initState() {
    super.initState();
    _schedule();
  }

  @override
  void didUpdateWidget(covariant _TranscriptLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.transcriptStatus != widget.message.transcriptStatus) {
      _schedule();
    }
  }

  void _schedule() {
    _queuedHold?.cancel();
    final status = widget.message.transcriptStatusValue;
    if (status == .failed) {
      _showUnavailable = true;
      return;
    }
    if (status == .queued) {
      _showUnavailable = false;
      _queuedHold = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showUnavailable = true);
      });
      return;
    }
    _showUnavailable = false;
  }

  @override
  void dispose() {
    _queuedHold?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showUnavailable && widget.message.transcriptStatusValue != .failed) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Text(
        l10n.chatVoiceTranscriptUnavailable,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: widget.foreground.withValues(alpha: 0.85),
        ),
      ),
    );
  }
}
