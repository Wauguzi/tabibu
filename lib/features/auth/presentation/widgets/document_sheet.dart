import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E2b/F2c's source choice. The caller picks through the file service:
/// the camera through `pickPhoto`, a file through `pickLicence`.
enum DocumentSource { camera, file }

/// E2b/F2c: photograph the page or upload a file. Dismissing pops null.
/// The caller passes its role's subtitle; without one the doctor's shows.
Future<DocumentSource?> showDocumentSheet(
  BuildContext context, {
  String? subtitle,
}) {
  final l10n = context.l10n;
  return TabibuBottomSheet.show<DocumentSource>(
    context,
    title: l10n.documentSheetTitle,
    subtitle: subtitle ?? l10n.documentSheetSubtitle,
    cancelLabel: l10n.commonCancel,
    builder: (context) => Column(
      mainAxisSize: .min,
      children: [
        OptionCard(
          icon: Assets.icons.photoIcon,
          tone: .sky,
          title: l10n.photoTake,
          supporting: l10n.documentTakePhotoBody,
          selected: false,
          chevron: true,
          onTap: () => Navigator.of(context).pop(DocumentSource.camera),
        ),
        const SizedBox(height: AppSpacing.sm),
        OptionCard(
          icon: Assets.icons.uploadIcon,
          tone: .lavender,
          title: l10n.documentUploadFile,
          supporting: l10n.documentUploadFileBody,
          selected: false,
          chevron: true,
          onTap: () => Navigator.of(context).pop(DocumentSource.file),
        ),
      ],
    ),
  );
}
