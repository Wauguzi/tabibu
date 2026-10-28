import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_gradients.dart';

/// The role wash behind a screen: the role's gradient up top, fading into
/// the surface below. Patient is sky to lavender, doctor mint to sky,
/// pathologist lavender to mint.
class RoleBackground extends StatelessWidget {
  const RoleBackground.patient({required this.child, super.key})
    : _role = _RoleWash.patient;
  const RoleBackground.doctor({required this.child, super.key})
    : _role = _RoleWash.doctor;
  const RoleBackground.pathologist({required this.child, super.key})
    : _role = _RoleWash.pathologist;

  final Widget child;
  final _RoleWash _role;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final wash = switch (_role) {
      _RoleWash.patient =>
        isDark ? AppGradients.skyToLavenderDark : AppGradients.skyToLavender,
      _RoleWash.doctor =>
        isDark ? AppGradients.mintToSkyDark : AppGradients.mintToSky,
      _RoleWash.pathologist =>
        isDark ? AppGradients.lavenderToMintDark : AppGradients.lavenderToMint,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            wash.colors[0],
            wash.colors[1],
            scheme.surface,
            scheme.surface,
          ],
          stops: const [0.0, 0.45, 0.75, 1.0],
        ),
      ),
      child: child,
    );
  }
}

enum _RoleWash { patient, doctor, pathologist }
