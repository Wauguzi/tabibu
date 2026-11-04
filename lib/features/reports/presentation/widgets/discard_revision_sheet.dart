import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Confirms leaving an open Amendment or Addendum draft unsigned. True when
/// the pathologist confirms, false when the sheet is dismissed.
abstract final class DiscardRevisionSheet {
  static Future<bool> show(BuildContext context) async =>
      await TabibuBottomSheet.show<bool>(
        context,
        title: context.l10n.workspaceDiscardSheetTitle,
        cancelLabel: context.l10n.commonCancel,
        builder: (sheet) => Column(
          crossAxisAlignment: .stretch,
          children: [
            Text(sheet.l10n.workspaceDiscardSheetBody),
            const SizedBox(height: AppSpacing.lg),
            TabibuButton.primary(
              label: sheet.l10n.workspaceDiscardSheetConfirm,
              onTap: () => Navigator.of(sheet).pop<bool>(true),
            ),
          ],
        ),
      ) ??
      false;
}
