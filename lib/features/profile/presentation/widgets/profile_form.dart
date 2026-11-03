import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// The rules' phone shape, as the client checks it before sending.
final _kenyanPhone = RegExp(r'^\+254[17][0-9]{8}$');

/// A typed phone number in the shape the rules take, or null when it
/// cannot be one. Spaces, dashes and brackets fall away; a leading 0 or
/// a missing +254 is added.
String? normalizeKenyanPhone(String input) {
  final digits = input.replaceAll(RegExp(r'[\s\-()]'), '');
  final shaped = digits.startsWith('+')
      ? digits
      : digits.startsWith('254')
      ? '+$digits'
      : digits.startsWith('0') && digits.length == 10
      ? '+254${digits.substring(1)}'
      : digits.length == 9
      ? '+254$digits'
      : digits;
  return _kenyanPhone.hasMatch(shaped) ? shaped : null;
}

/// "9:00 AM–4:00 PM": the one daily range all working days share, in the
/// device's time format.
String hoursRangeText(BuildContext context, int startMinute, int endMinute) {
  String at(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60).format(context);
  return '${at(startMinute)}\u2013${at(endMinute)}';
}

/// "Mon–Fri": the working days as one span when they run together, one day,
/// or a comma list. Empty stays empty; the caller shows Closed.
String workingDaysSummary(String languageCode, Set<int> days) {
  if (days.isEmpty) return '';
  final sorted = days.toList()..sort();
  String name(int weekday) => DateFormat(
    'EEE',
    languageCode,
    // 26 Oct 2026 is a Monday; the weekday counts from it.
  ).format(DateTime.utc(2026, 10, 25 + weekday));
  if (sorted.length == 1) return name(sorted.single);
  final consecutive = sorted.last - sorted.first == sorted.length - 1;
  if (consecutive) return '${name(sorted.first)}\u2013${name(sorted.last)}';
  return sorted.map(name).join(', ');
}

/// The edit screens' photo: the stored picture (or picked bytes) under a
/// Change pill that opens the camera/library sheet. Failures toast.
/// [url] is the stored picture, [picked] the bytes chosen since.
class ProfilePhotoEditor extends StatefulWidget {
  const ProfilePhotoEditor({
    required this.name,
    required this.changeLabel,
    required this.onPicked,
    this.url = '',
    this.picked,
    super.key,
  });

  final String name;
  final String changeLabel;
  final ValueChanged<UploadFile> onPicked;
  final String url;
  final Uint8List? picked;

  @override
  State<ProfilePhotoEditor> createState() => _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends State<ProfilePhotoEditor> {
  bool _reading = false;

  Future<void> _pick(bool fromCamera) async {
    setState(() => _reading = true);
    try {
      final file = await getIt<FilePickerService>().pickPhoto(
        fromCamera: fromCamera,
      );
      if (!mounted) return;
      if (file != null) widget.onPicked(file);
    } on AppError catch (error) {
      if (!mounted) return;
      final l10n = context.l10n;
      unawaited(
        showTabibuNotification(
          context,
          message: error.description(l10n),
          isError: true,
          dismissLabel: l10n.commonDismiss,
        ),
      );
    } on Object catch (_) {
      if (!mounted) return;
      final l10n = context.l10n;
      unawaited(
        showTabibuNotification(
          context,
          message: AppError.unknown.description(l10n),
          isError: true,
          dismissLabel: l10n.commonDismiss,
        ),
      );
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _sheet() async {
    // One pick at a time: a second would race the first to onPicked.
    if (_reading) return;
    final l10n = context.l10n;
    final fromCamera = await TabibuBottomSheet.show<bool>(
      context,
      title: l10n.photoTitle,
      cancelLabel: l10n.commonCancel,
      builder: (context) => Column(
        mainAxisSize: .min,
        children: [
          OptionCard(
            icon: Assets.icons.photoIcon,
            tone: .sky,
            title: l10n.photoTake,
            selected: false,
            chevron: true,
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.sm),
          OptionCard(
            icon: Assets.icons.uploadIcon,
            tone: .lavender,
            title: l10n.photoLibrary,
            selected: false,
            chevron: true,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    if (fromCamera == null || !context.mounted) return;
    await _pick(fromCamera);
  }

  @override
  Widget build(BuildContext context) {
    final picked = widget.picked;
    return Column(
      children: [
        Avatar(
          name: widget.name,
          image: picked != null
              ? MemoryImage(picked)
              : (widget.url.isEmpty ? null : NetworkImage(widget.url)),
          radius: 44,
        ),
        const SizedBox(height: AppSpacing.sm),
        Tappable(
          onTap: _reading ? null : _sheet,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                AssetIcon(Assets.icons.photoIcon, size: 18),
                const SizedBox(width: AppSpacing.xs),
                // Long labels at large text wrap instead of overflowing.
                Flexible(
                  child: Text(
                    widget.changeLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
