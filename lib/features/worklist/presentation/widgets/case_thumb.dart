import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A rounded slide thumbnail for the desk: image or a neutral test-tube
/// placeholder, with an optional ink rank badge (decorative).
class CaseThumb extends StatelessWidget {
  const CaseThumb({this.image, this.rank, this.size = 56, super.key});

  final ImageProvider? image;
  final int? rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final isDark = scheme.brightness == .dark;
    final onInk = isDark ? AppColors.inkLight : Colors.white;
    final image = this.image;
    final rank = this.rank;
    final radius = BorderRadius.circular(AppRadii.field);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: .none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: radius,
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: image == null
                    ? Center(
                        child: AssetIcon(
                          Assets.icons.testTubeIcon,
                          size: size * 0.4,
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    : Image(image: image, fit: .cover),
              ),
            ),
          ),
          if (rank != null)
            Positioned(
              top: -4,
              left: -4,
              child: ExcludeSemantics(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: status.ink, shape: .circle),
                  alignment: .center,
                  child: Text(
                    '$rank',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: onInk,
                      fontWeight: .w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
