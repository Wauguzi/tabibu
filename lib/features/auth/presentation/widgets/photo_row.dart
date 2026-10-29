import 'dart:async';

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

/// D1, E1 and F1's photo row: the avatar, what it is for, and the Add/Change
/// pill, which opens the camera-or-library sheet. A refused or oversized
/// pick shows its message; a cancelled one shows nothing. The picked bytes
/// are read after the sheet closes; [onReading] reports the wait, with
/// progress on the avatar, so the step holds its Continue meanwhile.
class PhotoRow extends StatefulWidget {
  const PhotoRow({
    required this.name,
    required this.title,
    required this.body,
    required this.picture,
    required this.onPicked,
    required this.onReading,
    this.required = false,
    this.errorText,
    super.key,
  });

  /// The name behind the avatar's initials while no photo is set.
  final String name;
  final String title;
  final String body;
  final UploadFile? picture;
  final ValueChanged<UploadFile> onPicked;

  /// True while the picked photo is read, false once it lands or fails.
  final ValueChanged<bool> onReading;
  final bool required;
  final String? errorText;

  @override
  State<PhotoRow> createState() => _PhotoRowState();
}

class _PhotoRowState extends State<PhotoRow> {
  bool _reading = false;

  Future<void> _pick(bool fromCamera) async {
    setState(() => _reading = true);
    widget.onReading(true);
    try {
      final file = await getIt<FilePickerService>().pickPhoto(
        fromCamera: fromCamera,
      );
      if (!context.mounted) return;
      if (file != null) widget.onPicked(file);
    } on AppError catch (error) {
      if (!context.mounted) return;
      _failed(error);
    } on Object catch (_) {
      if (!context.mounted) return;
      _failed(AppError.unknown);
    } finally {
      if (mounted) {
        setState(() => _reading = false);
        widget.onReading(false);
      }
    }
  }

  void _failed(AppError error) {
    final l10n = context.l10n;
    unawaited(
      showTabibuNotification(
        context,
        message: error.description(l10n),
        isError: true,
        dismissLabel: l10n.commonDismiss,
      ),
    );
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
        mainAxisSize: MainAxisSize.min,
        children: [
          OptionCard(
            icon: Assets.icons.photoIcon,
            tone: IconTone.sky,
            title: l10n.photoTake,
            selected: false,
            trailing: AssetIcon(Assets.icons.forwardIcon, size: 22),
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.sm),
          OptionCard(
            icon: Assets.icons.uploadIcon,
            tone: IconTone.lavender,
            title: l10n.photoLibrary,
            selected: false,
            trailing: AssetIcon(Assets.icons.forwardIcon, size: 22),
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
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final picture = widget.picture;

    final nameless = picture == null && widget.name.trim().isEmpty;
    final errorText = widget.errorText;

    final Widget avatar;
    if (nameless) {
      avatar = Container(
        width: 56,
        height: 56,
        alignment: .center,
        decoration: BoxDecoration(
          shape: .circle,
          color: scheme.surfaceContainerHigh,
        ),
        child: ExcludeSemantics(
          child: AssetIcon(
            Assets.icons.personIcon,
            size: 22,
            scaleUp: false,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    } else if (picture == null) {
      avatar = Avatar(name: widget.name, radius: 28);
    } else {
      avatar = Avatar(
        name: widget.name,
        image: MemoryImage(picture.bytes),
        radius: 28,
      );
    }

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            if (_reading)
              Stack(
                alignment: .center,
                children: [
                  avatar,
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(color: scheme.primary),
                  ),
                ],
              )
            else
              avatar,
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: widget.title,
                      style: textTheme.titleMedium,
                      children: [
                        if (widget.required)
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: scheme.error),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    widget.body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              button: true,
              onTap: _sheet,
              child: GestureDetector(
                onTap: _sheet,
                behavior: .opaque,
                // The 48 dp floor wraps the hit area; the drawn pill keeps
                // its size, centered in the row's height.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      Material(
                        color: scheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AssetIcon(Assets.icons.photoIcon, size: 20),
                              const SizedBox(width: AppSpacing.xxs),
                              Text(
                                picture == null
                                    ? l10n.photoAdd
                                    : l10n.photoChange,
                                style: textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText,
            style: textTheme.bodySmall?.copyWith(color: scheme.error),
            maxLines: 3,
          ),
        ],
      ],
    );
  }
}
