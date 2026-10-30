import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// A role's home: its four tabs under the floating menu. Doctors and
/// pathologists have MDT before Profile. Back from another tab returns to
/// the first before it leaves the app.
class HomeShell extends StatelessWidget {
  const HomeShell({
    required this.role,
    required this.navigationShell,
    super.key,
  });

  final Role role;
  final StatefulNavigationShell navigationShell;

  List<FloatingTab> _tabs(AppLocalizations l10n) {
    final profile = FloatingTab(
      icon: Assets.icons.personIcon,
      label: l10n.tabProfile,
    );
    final mdt = FloatingTab(icon: Assets.icons.mdtIcon, label: l10n.tabMdt);
    return switch (role) {
      .patient => [
        FloatingTab(icon: Assets.icons.homeIcon, label: l10n.tabHome),
        FloatingTab(
          icon: Assets.icons.appointmentsIcon,
          label: l10n.tabAppointments,
        ),
        FloatingTab(icon: Assets.icons.resultsIcon, label: l10n.tabResults),
        profile,
      ],
      .doctor => [
        FloatingTab(icon: Assets.icons.homeIcon, label: l10n.tabToday),
        FloatingTab(icon: Assets.icons.resultsIcon, label: l10n.tabCases),
        mdt,
        profile,
      ],
      .pathologist => [
        FloatingTab(icon: Assets.icons.deskIcon, label: l10n.tabDesk),
        FloatingTab(icon: Assets.icons.signedIcon, label: l10n.tabSigned),
        mdt,
        profile,
      ],
    };
  }

  // A tap on the open tab takes it back to its first screen.
  void _select(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;
    return PopScope(
      canPop: current == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            child: Center(
              heightFactor: 1,
              child: FloatingTabBar(
                tabs: _tabs(context.l10n),
                currentIndex: current,
                onSelected: _select,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
