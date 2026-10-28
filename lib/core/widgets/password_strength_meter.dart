import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Password strength: four bars with a word, plus the checklist. Renders
/// nothing while the password is empty. Rule labels and the strength word
/// come from the caller; only the checks are fixed.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    required this.password,
    required this.strengthWord,
    required this.lengthLabel,
    required this.numberLabel,
    required this.symbolLabel,
    super.key,
  });

  final String password;
  final String strengthWord;
  final String lengthLabel;
  final String numberLabel;
  final String symbolLabel;

  bool get _longEnough => password.length >= 8;
  bool get _hasNumber => RegExp('[0-9]').hasMatch(password);
  bool get _hasSymbol => RegExp('[^A-Za-z0-9]').hasMatch(password);

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    final met = [_longEnough, _hasNumber, _hasSymbol];
    final filled = met.where((m) => m).length + 1;
    final complete = filled == 4;
    final barColor = complete ? status.signedDot : scheme.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (var i = 0; i < 4; i++) ...[
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < filled
                          ? barColor
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (i < 3) const SizedBox(width: AppSpacing.xxs),
              ],
              const SizedBox(width: AppSpacing.sm),
              Text(
                strengthWord,
                style: textTheme.titleSmall?.copyWith(color: barColor),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _RuleRow(label: lengthLabel, met: _longEnough),
          _RuleRow(label: numberLabel, met: _hasNumber),
          _RuleRow(label: symbolLabel, met: _hasSymbol),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? status.signedDot : Colors.transparent,
              border: met
                  ? null
                  : Border.all(color: scheme.outlineVariant, width: 1.5),
            ),
            alignment: Alignment.center,
            child: met
                ? AssetIcon(
                    Assets.icons.tickIcon,
                    size: 12,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: met ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
