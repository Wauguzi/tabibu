import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A role tab's page: the role's wash behind a scrolling column. The shell
/// extends its body under the floating menu and adds the menu's height to
/// the bottom padding, so the last row scrolls clear of it.
///
/// Give [onRefresh] for pull-to-refresh; the page always scrolls, so an
/// empty or short list can still be pulled.
class ShellTabPage extends StatelessWidget {
  const ShellTabPage({
    required this.role,
    this.children,
    this.slivers,
    this.onRefresh,
    super.key,
  }) : assert(
         (children == null) != (slivers == null),
         'Give exactly one of children or slivers.',
       );

  final Role role;
  final List<Widget>? children;
  final List<Widget>? slivers;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(
      AppSpacing.screenMargin,
      AppSpacing.md,
      AppSpacing.screenMargin,
      MediaQuery.paddingOf(context).bottom + AppSpacing.md,
    );
    Widget scroll = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: slivers == null
              ? SliverList.list(children: children!)
              : SliverMainAxisGroup(slivers: slivers!),
        ),
      ],
    );
    final refresh = onRefresh;
    if (refresh != null) {
      scroll = RefreshIndicator.adaptive(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: refresh,
        child: scroll,
      );
    }
    final content = SafeArea(bottom: false, child: scroll);
    return Scaffold(
      body: switch (role) {
        .patient => RoleBackground.patient(child: content),
        .doctor => RoleBackground.doctor(child: content),
        .pathologist => RoleBackground.pathologist(child: content),
      },
    );
  }
}
