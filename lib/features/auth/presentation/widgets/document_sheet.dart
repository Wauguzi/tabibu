import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E2b/F2c's source choice. The caller picks through the file service:
/// the camera through `pickPhoto`, a file through `pickLicence`.
enum DocumentSource { camera, file }

/// E2b/F2c: photograph the page or upload a file. Dismissing pops null.
Future<DocumentSource?> showDocumentSheet(BuildContext context) {
  final l10n = context.l10n;
  return TabibuBottomSheet.show<DocumentSource>(
    context,
    title: l10n.documentSheetTitle,
    closeLabel: l10n.commonClose,
    subtitle: l10n.documentSheetSubtitle,
    cancelLabel: l10n.commonCancel,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OptionCard(
          icon: Assets.icons.photoIcon,
          tone: IconTone.sky,
          title: l10n.photoTake,
          supporting: l10n.documentTakePhotoBody,
          selected: false,
          trailing: AssetIcon(Assets.icons.forwardIcon, size: 22),
          onTap: () => Navigator.of(context).pop(DocumentSource.camera),
        ),
        const SizedBox(height: AppSpacing.sm),
        OptionCard(
          icon: Assets.icons.uploadIcon,
          tone: IconTone.lavender,
          title: l10n.documentUploadFile,
          supporting: l10n.documentUploadFileBody,
          selected: false,
          trailing: AssetIcon(Assets.icons.forwardIcon, size: 22),
          onTap: () => Navigator.of(context).pop(DocumentSource.file),
        ),
      ],
    ),
  );
}
