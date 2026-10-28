import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A status mark: a small circle showing state, not content. Done is signed
/// green with a white check, current is ink with a white icon, pending is a
/// muted icon on a quiet fill, and selection is an ink check-circle when on
/// and an outline circle when off.
class StatusMark extends StatelessWidget {
  const StatusMark.done({required this.label, this.diameter = 32, super.key})
    : _state = _MarkState.done,
      icon = null,
      selected = false;

  const StatusMark.current({
    required this.icon,
    required this.label,
    this.diameter = 32,
    super.key,
  }) : _state = _MarkState.current,
       selected = false;

  const StatusMark.pending({
    required this.icon,
    required this.label,
    this.diameter = 32,
    super.key,
  }) : _state = _MarkState.pending,
       selected = false;

  const StatusMark.selection({
    required this.selected,
    required this.label,
    this.diameter = 24,
    super.key,
  }) : _state = _MarkState.selection,
       icon = null;

  final SvgGenImage? icon;
  final double diameter;
  final _MarkState _state;
  final bool selected;

  /// The state announced to screen readers, from the caller.
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;

    if (_state == _MarkState.selection) {
      return Semantics(
        label: label,
        child: AssetIcon(
          selected
              ? Assets.icons.checkSelectedIcon
              : Assets.icons.checkUnselectedIcon,
          size: diameter,
        ),
      );
    }

    final (background, foreground, glyph) = switch (_state) {
      _MarkState.done => (
        status.signedDot,
        Colors.white,
        Assets.icons.tickIcon,
      ),
      _MarkState.current => (status.ink, Colors.white, icon!),
      _MarkState.pending => (
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
        icon!,
      ),
      _MarkState.selection => throw StateError('unreachable'),
    };

    return Semantics(
      label: label,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: AssetIcon(glyph, size: 16, color: foreground),
      ),
    );
  }
}

enum _MarkState { done, current, pending, selection }
