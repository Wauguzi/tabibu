import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/appointments/data/slot_planner.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-06 Pick a date: the booking window as a month grid in Nairobi time.
/// Days with free times carry a dot; past, empty and out-of-window days are
/// grey and cannot be picked. Pops the picked day, or null on dismiss.
abstract final class MonthDateSheet {
  static Future<DateTime?> show(
    BuildContext context, {
    required List<PlannedDay> days,
    required DateTime selected,
  }) => TabibuBottomSheet.show<DateTime>(
    context,
    builder: (_) => _MonthGrid(days: days, selected: selected),
  );
}

class _MonthGrid extends StatefulWidget {
  const _MonthGrid({required this.days, required this.selected});

  final List<PlannedDay> days;
  final DateTime selected;

  @override
  State<_MonthGrid> createState() => _MonthGridState();
}

class _MonthGridState extends State<_MonthGrid> {
  late DateTime _month;
  late DateTime? _selected;

  /// The planner's days by date: the booking window's edges.
  late final Map<DateTime, PlannedDay> _byDay = {
    for (final day in widget.days) day.date: day,
  };

  @override
  void initState() {
    super.initState();
    final selected = widget.selected;
    // The strip allows a dimmed day; the sheet opens on the first day with
    // times instead, or nothing when the window holds none.
    _selected = _byDay[selected]?.available == true
        ? selected
        : _byDay.values
              .where((day) => day.available)
              .map((day) => day.date)
              .firstOrNull;
    final anchor = _selected ?? selected;
    _month = DateTime.utc(anchor.year, anchor.month);
  }

  DateTime get _firstMonth {
    final first = widget.days.firstOrNull?.date;
    if (first == null) return _month;
    return DateTime.utc(first.year, first.month);
  }

  DateTime get _lastMonth {
    final last = widget.days.lastOrNull?.date;
    if (last == null) return _month;
    return DateTime.utc(last.year, last.month);
  }

  bool get _canPrev =>
      _month.year > _firstMonth.year ||
      (_month.year == _firstMonth.year && _month.month > _firstMonth.month);

  bool get _canNext =>
      _month.year < _lastMonth.year ||
      (_month.year == _lastMonth.year && _month.month < _lastMonth.month);

  void _page(int delta) => setState(() {
    _month = DateTime.utc(_month.year, _month.month + delta);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    final selected = _selected;
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        _Pager(
          month: _month,
          language: language,
          canPrev: _canPrev,
          canNext: _canNext,
          onPrev: () => _page(-1),
          onNext: () => _page(1),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Grid(
          month: _month,
          language: language,
          byDay: _byDay,
          selected: selected,
          onSelect: (date) => setState(() => _selected = date),
        ),
        const SizedBox(height: AppSpacing.sm),
        _Legend(label: l10n.datePickerTimesFree),
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.md),
          TabibuButton.primary(
            label: l10n.datePickerShowTimes(
              DateFormat('EEE d MMM', language).format(selected),
            ),
            onTap: () => Navigator.of(context).pop(selected),
          ),
        ],
      ],
    );
  }
}

/// Sky circles around the centred month, muted at the window's edges.
class _Pager extends StatelessWidget {
  const _Pager({
    required this.month,
    required this.language,
    required this.canPrev,
    required this.canNext,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final String language;
  final bool canPrev;
  final bool canNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final months = DateFormat('MMMM y', language);
    return Row(
      children: [
        _PageButton(
          icon: Assets.icons.backIcon,
          label: months.format(DateTime.utc(month.year, month.month - 1)),
          enabled: canPrev,
          onTap: onPrev,
        ),
        Expanded(
          child: Text(
            months.format(month),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: .w600),
            textAlign: .center,
          ),
        ),
        _PageButton(
          icon: Assets.icons.forwardIcon,
          label: months.format(DateTime.utc(month.year, month.month + 1)),
          enabled: canNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == .dark;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: enabled
              ? (isDark ? AppColors.skyDark : AppColors.skyLight)
              : AppColors.transparent,
          shape: const CircleBorder(),
          child: Tappable(
            onTap: enabled ? onTap : null,
            child: Center(
              child: AssetIcon(
                icon,
                size: 20,
                color: enabled
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Monday-first grid. Free days are bold ink with a dot and can be
/// picked; anything else is grey. The selected day is an ink rounded
/// square.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.month,
    required this.language,
    required this.byDay,
    required this.selected,
    required this.onSelect,
  });

  final DateTime month;
  final String language;
  final Map<DateTime, PlannedDay> byDay;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final first = DateTime.utc(month.year, month.month);
    final lead = (first.weekday - DateTime.monday) % 7;
    final daysInMonth = DateTime.utc(month.year, month.month + 1, 0).day;
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < 7; i++)
          Center(
            child: Text(
              // 2024-01-01 was a Monday.
              DateFormat(
                'EEEEE',
                language,
              ).format(DateTime.utc(2024, 1, 1 + i)),
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        for (var i = 0; i < lead; i++) const SizedBox.shrink(),
        for (var day = 1; day <= daysInMonth; day++)
          _Cell(
            date: DateTime.utc(month.year, month.month, day),
            language: language,
            available:
                byDay[DateTime.utc(month.year, month.month, day)]?.available ??
                false,
            selected:
                selected != null &&
                DateTime.utc(month.year, month.month, day) == selected,
            onSelect: onSelect,
          ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.date,
    required this.language,
    required this.available,
    required this.selected,
    required this.onSelect,
  });

  final DateTime date;
  final String language;
  final bool available;
  final bool selected;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final isDark = scheme.brightness == .dark;
    final label = DateFormat('EEE d MMM', language).format(date);
    final onTap = available ? () => onSelect(date) : null;
    final cell = Container(
      decoration: selected
          ? BoxDecoration(
              color: status.ink,
              borderRadius: BorderRadius.circular(AppRadii.field),
            )
          : null,
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          Text(
            '${date.day}',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: available ? .w700 : .w400,
              color: selected
                  ? (isDark ? AppColors.inkLight : AppColors.white)
                  : available
                  ? scheme.onSurface
                  : scheme.onSurfaceVariant,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: selected
                  ? (isDark ? AppColors.inkLight : AppColors.white)
                  : available
                  ? status.signedDot
                  : AppColors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        enabled: onTap != null,
        label: label,
        onTap: onTap,
        child: Tappable(
          onTap: onTap,
          child: ExcludeSemantics(child: cell),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final status = Theme.of(context).extension<AppStatusColors>()!;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: status.signedDot,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
