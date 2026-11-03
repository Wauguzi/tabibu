import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A day group's draft from its sheet: whether the days stay open, and the
/// one range every open day shares.
typedef HoursDraft = ({bool open, int startMinute, int endMinute});

/// The weekdays/Saturday/Sunday editors as bottom sheets (D-HOURS). The
/// switch keeps or drops the group's days; Opens and Closes set the one
/// range the backend keeps for all days. The frame's lunch break stays out:
/// it has no field. Answers null when dismissed.
Future<HoursDraft?> showHoursSheet({
  required BuildContext context,
  required String title,
  required bool open,
  required int startMinute,
  required int endMinute,
}) => TabibuBottomSheet.show<HoursDraft>(
  context,
  title: title,
  builder: (context) =>
      _HoursBody(open: open, startMinute: startMinute, endMinute: endMinute),
);

class _HoursBody extends StatefulWidget {
  const _HoursBody({
    required this.open,
    required this.startMinute,
    required this.endMinute,
  });

  final bool open;
  final int startMinute;
  final int endMinute;

  @override
  State<_HoursBody> createState() => _HoursBodyState();
}

class _HoursBodyState extends State<_HoursBody> {
  late bool _open = widget.open;
  late int _start = widget.startMinute;
  late int _end = widget.endMinute;
  bool _badRange = false;

  /// The picker lands anywhere; the rules take the :00/:30 grid inside the
  /// day, so the pick rounds to the nearest half hour.
  int _grid(TimeOfDay picked) {
    final rounded = (picked.hour * 60 + picked.minute + 15) ~/ 30 * 30;
    return rounded.clamp(0, 1410);
  }

  Future<void> _pick(bool isStart) async {
    final minutes = isStart ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _start = _grid(picked);
      } else {
        _end = _grid(picked);
      }
      _badRange = false;
    });
  }

  void _save() {
    if (_end - _start < 30) {
      setState(() => _badRange = true);
      return;
    }
    Navigator.of(
      context,
    ).pop((open: _open, startMinute: _start, endMinute: _end));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final badRange = _badRange;
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _open ? l10n.clinicHoursOpen : l10n.clinicHoursClosedDay,
                  style: textTheme.titleMedium,
                ),
              ),
              Switch(
                value: _open,
                onChanged: (value) => setState(() => _open = value),
                materialTapTargetSize: .shrinkWrap,
              ),
            ],
          ),
        ),
        if (_open) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.clinicHoursOpens,
                  style: textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.clinicHoursCloses,
                  style: textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TabibuButton.outline(
                  label: TimeOfDay(
                    hour: _start ~/ 60,
                    minute: _start % 60,
                  ).format(context),
                  icon: AssetIcon(Assets.icons.clockIcon, size: 20),
                  onTap: () => _pick(true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TabibuButton.outline(
                  label: TimeOfDay(
                    hour: _end ~/ 60,
                    minute: _end % 60,
                  ).format(context),
                  icon: AssetIcon(Assets.icons.clockIcon, size: 20),
                  onTap: () => _pick(false),
                ),
              ),
            ],
          ),
          if (badRange) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.clinicHoursBadRange,
              style: textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.md),
        NoticeCard(
          variant: .info,
          icon: Assets.icons.infoIcon,
          body: l10n.clinicHoursBookedStay,
        ),
        const SizedBox(height: AppSpacing.md),
        TabibuButton.primary(label: l10n.clinicHoursSave, onTap: _save),
      ],
    );
  }
}
