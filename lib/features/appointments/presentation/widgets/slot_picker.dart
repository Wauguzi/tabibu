import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/features/appointments/presentation/widgets/day_strip.dart';
import 'package:tabibu/features/appointments/presentation/widgets/slot_chip_row.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The booking flow's day-and-time picker, shared by the reschedule and move
/// sheets: a day strip over [days] and the chosen day's slot chips. Reports
/// the picked slot, or null when the day changes.
class SlotPicker extends StatefulWidget {
  const SlotPicker({
    required this.days,
    required this.onPick,
    required this.dayLabel,
    required this.timeLabel,
    super.key,
  });

  final List<PlannedDay> days;
  final ValueChanged<PlannedSlot?> onPick;

  /// The day section header ("New day").
  final String dayLabel;

  /// The time section header for the chosen day ("New time · {date}").
  final String Function(String date) timeLabel;

  @override
  State<SlotPicker> createState() => _SlotPickerState();
}

class _SlotPickerState extends State<SlotPicker> {
  late int _dayIndex = widget.days.indexWhere((d) => d.available);
  int? _slotIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final dayIndex = _dayIndex.clamp(0, widget.days.length - 1);
    final day = widget.days[dayIndex];
    String slotLabel(DateTime start) =>
        DateFormat('h:mm a', language).format(nairobiNow(start));
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(widget.dayLabel, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        DayStrip(
          days: [
            for (final option in widget.days)
              DayOption(
                weekday: DateFormat('EEE', language).format(option.date),
                day: DateFormat('d', language).format(option.date),
                available: option.available,
              ),
          ],
          selected: dayIndex,
          onSelected: (index) => setState(() {
            _dayIndex = index;
            _slotIndex = null;
            widget.onPick(null);
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.timeLabel(DateFormat('EEE d MMM', language).format(day.date)),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        SlotChipRow(
          slots: [
            for (final slot in day.slots)
              SlotOption(
                label: slotLabel(slot.start),
                taken: slot.taken,
                semanticLabel: slot.taken
                    ? l10n.pickTimeSlotTaken(slotLabel(slot.start))
                    : null,
              ),
          ],
          selected: _slotIndex,
          onSelected: (index) => setState(() {
            _slotIndex = index;
            widget.onPick(day.slots[index]);
          }),
        ),
      ],
    );
  }
}
