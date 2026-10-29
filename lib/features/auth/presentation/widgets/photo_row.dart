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
/// pick shows its message; a cancelled one shows nothing.
class PhotoRow extends StatelessWidget {
  const PhotoRow({
    required this.name,
    required this.title,
    required this.body,
    required this.picture,
    required this.onPicked,
    this.required = false,
    super.key,
  });

  /// The name behind the avatar's initials while no photo is set.
  final String name;
  final String title;
  final String body;
  final UploadFile? picture;
  final ValueChanged<UploadFile> onPicked;
  final bool required;

  Future<void> _pick(BuildContext context, bool fromCamera) async {
    try {
      final file = await getIt<FilePickerService>().pickPhoto(
        fromCamera: fromCamera,
      );
      if (file != null) onPicked(file);
    } on AppError catch (error) {
      if (!context.mounted) return;
      _failed(context, error);
    } on Object catch (_) {
      if (!context.mounted) return;
      _failed(context, AppError.unknown);
    }
  }

  void _failed(BuildContext context, AppError error) {
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

  Future<void> _sheet(BuildContext context) async {
    final l10n = context.l10n;
    final fromCamera = await TabibuBottomSheet.show<bool>(
      context,
      title: l10n.photoTitle,
      closeLabel: l10n.commonClose,
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
    await _pick(context, fromCamera);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final picture = this.picture;

    return Row(
      children: [
        if (picture == null)
          Avatar(name: name, radius: 28)
        else
          Avatar(name: name, image: MemoryImage(picture.bytes), radius: 28),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: title,
                  style: textTheme.titleMedium,
                  children: [
                    if (required)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: scheme.error),
                      ),
                  ],
                ),
              ),
              Text(
                body,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Material(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: InkWell(
            onTap: () => _sheet(context),
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
                    picture == null ? l10n.photoAdd : l10n.photoChange,
                    style: textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
