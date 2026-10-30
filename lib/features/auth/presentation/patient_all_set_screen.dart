import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D5. The account is ready; its button leaves through [goToSession].
class PatientAllSetScreen extends StatelessWidget {
  const PatientAllSetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final session = context.watch<AuthBloc>().state.session;
    final name = session is PatientSession
        ? session.patient.firstName
        : context.watch<SignUpBloc>().state.draft.firstName;

    return RoleBackground.patient(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenMargin),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        const Center(
                          child: ExcludeSemantics(
                            child: _CalendarIllustration(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.allSetTitle(name),
                          style: textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.allSetSubtitle,
                          style: textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.md),
                        TabibuButton.primary(
                          label: l10n.allSetButton,
                          onTap: () => goToSession(context, session),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// D5's calendar illustration, built from design tokens rather than an
/// image: the mint-headed calendar, one teal date, the check badge and
/// three sparkles. Fixed light colors, as drawn, in both modes.
class _CalendarIllustration extends StatelessWidget {
  const _CalendarIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 180,
      child: Stack(
        children: [
          Positioned(
            left: 40,
            top: 24,
            child: Container(
              width: 112,
              height: 126,
              decoration: BoxDecoration(
                color: AppColors.surfaceLowestLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.inkLight, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Container(
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.mintLight,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                    ),
                    Container(height: 2, color: AppColors.inkLight),
                    const Expanded(child: _DateDots()),
                  ],
                ),
              ),
            ),
          ),
          for (final left in [79.0, 108.0])
            Positioned(
              left: left,
              top: 14,
              child: Container(
                width: 8,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.inkLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          Positioned(
            left: 132,
            top: 124,
            child: Container(
              width: 48,
              height: 48,
              alignment: .center,
              decoration: const BoxDecoration(
                shape: .circle,
                color: AppColors.primaryLight,
              ),
              child: AssetIcon(
                Assets.icons.checkSelectedIcon,
                size: 26,
                color: Colors.white,
              ),
            ),
          ),
          const Positioned(left: 22, top: 14, child: _Sparkle(16)),
          const Positioned(left: 158, top: 6, child: _Sparkle(22)),
          const Positioned(left: 174, top: 78, child: _Sparkle(12)),
        ],
      ),
    );
  }
}

/// The calendar's 4-by-3 dates, one of them teal.
class _DateDots extends StatelessWidget {
  const _DateDots();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: .spaceEvenly,
        children: [
          for (var row = 0; row < 3; row++)
            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                for (var col = 0; col < 4; col++)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: row == 1 && col == 2
                          ? AppColors.primaryLight
                          : AppColors.outlineVariantLight,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A four-point glint, as around the calendar.
class _Sparkle extends StatelessWidget {
  const _Sparkle(this.size);

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _SparklePainter());
  }
}

class _SparklePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final path = Path()
      ..moveTo(s / 2, 0)
      ..quadraticBezierTo(s / 2, s / 2, s, s / 2)
      ..quadraticBezierTo(s / 2, s / 2, s / 2, s)
      ..quadraticBezierTo(s / 2, s / 2, 0, s / 2)
      ..quadraticBezierTo(s / 2, s / 2, s / 2, 0);
    canvas.drawPath(path, Paint()..color = AppColors.inkLight);
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => false;
}
