import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/role_helper.dart';
import 'package:tabibu/core/utils/nairobi_time.dart';
import 'package:tabibu/core/utils/settle_refresh.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_bloc.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_event.dart';
import 'package:tabibu/features/notifications/blocs/notifications_bloc/notifications_state.dart';
import 'package:tabibu/features/notifications/data/models/notification_model.dart';
import 'package:tabibu/features/notifications/presentation/notification_target.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-02, PA-05 and the doctor notifications frame. One inbox for all three
/// roles; only the empty sentence changes with the role (N-19).
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({required this.role, super.key});

  final Role role;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

enum _MenuAction { markAllRead, refresh }

enum _Group { today, yesterday, earlier }

class _NotificationsScreenState extends State<NotificationsScreen> {
  final GlobalKey _menuKey = GlobalKey();

  late final String _uid;
  late final RoleHelper _roles;

  /// Africa/Nairobi is a fixed UTC+3 with no daylight saving; grouping and
  /// times use it, never the device zone (N-10).

  @override
  void initState() {
    super.initState();
    final session = context.read<AuthBloc>().state.session;
    _uid = switch (session) {
      PatientSession(:final patient) => patient.uid,
      PractitionerSession(:final doctor) => doctor.uid,
      _ => '',
    };
    _roles = switch (session) {
      PatientSession(:final roles) => roles,
      PractitionerSession(:final roles) => roles,
      _ => RoleHelper.none,
    };
    context.read<NotificationsBloc>().add(NotificationsRequested(uid: _uid));
  }

  Future<void> _refresh() async {
    final bloc = context.read<NotificationsBloc>()
      ..add(NotificationsRefreshed(uid: _uid));
    await settleRefresh<NotificationsState>(
      bloc.stream,
      (state) => state is NotificationsLoadInProgress,
    );
  }

  Future<void> _openMenu() async {
    final action = await showOptionsMenu<_MenuAction>(
      context,
      anchor: _menuKey,
      actions: [
        OptionsAction(
          value: _MenuAction.markAllRead,
          icon: Assets.icons.tickIcon,
          label: context.l10n.notificationsMarkAllRead,
        ),
        OptionsAction(
          value: _MenuAction.refresh,
          icon: Assets.icons.refreshIcon,
          label: context.l10n.notificationsRefresh,
        ),
      ],
    );
    if (!mounted) return;
    switch (action) {
      case _MenuAction.markAllRead:
        context.read<NotificationsBloc>().add(
          NotificationsAllReadRequested(uid: _uid),
        );
      case _MenuAction.refresh:
        context.read<NotificationsBloc>().add(
          NotificationsRefreshed(uid: _uid),
        );
      case null:
        break;
    }
  }

  void _onRowTap(NotificationModel row) {
    context.read<NotificationsBloc>().add(
      NotificationReadRequested(uid: _uid, notificationUid: row.uid),
    );
    // Share-first (T-18), same path as push and banner taps.
    final target = notificationRowTarget(row, _roles);
    unawaited(target?.push<void>(context));
  }

  _Group _groupOf(DateTime? time, DateTime now) {
    if (time == null) return _Group.earlier;
    final behind = nairobiDaysBefore(time, now);
    if (behind <= 0) return _Group.today;
    if (behind == 1) return _Group.yesterday;
    return _Group.earlier;
  }

  String? _trailingText(DateTime? time, DateTime now, Locale locale) {
    if (time == null) return null;
    final behind = nairobiDaysBefore(time, now);
    final tag = locale.toString();
    if (behind <= 0) return DateFormat('h:mm a', tag).format(time);
    if (behind < 7) return DateFormat('EEE', tag).format(time);
    return DateFormat('d MMM', tag).format(time);
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationsLoadFailure) {
            unawaited(
              showTabibuNotification(
                context,
                message: state.error.description(context.l10n),
                isError: true,
                dismissLabel: context.l10n.commonDismiss,
              ),
            );
          }
        },
        builder: (context, state) => RefreshIndicator.adaptive(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: _slivers(context, state),
          ),
        ),
      ),
    );
    return Scaffold(
      body: switch (widget.role) {
        .patient => RoleBackground.patient(child: body),
        .doctor => RoleBackground.doctor(child: body),
        .pathologist => RoleBackground.pathologist(child: body),
      },
    );
  }

  List<Widget> _slivers(BuildContext context, NotificationsState state) {
    const sides = EdgeInsets.fromLTRB(
      AppSpacing.screenMargin,
      AppSpacing.md,
      AppSpacing.screenMargin,
      0,
    );
    final l10n = context.l10n;
    final items = state.items;
    final loaded =
        state is NotificationsLoadSuccess || state is NotificationsLoadFailure;
    return [
      SliverPadding(
        padding: sides,
        sliver: SliverToBoxAdapter(
          child: TopBar(
            title: l10n.notificationsTitle,
            backLabel: l10n.commonBack,
            onBack: context.pop,
            // The doctor's empty frame has no menu (N-19).
            trailing: items.isEmpty && loaded
                ? null
                : MoreButton(
                    key: _menuKey,
                    semanticLabel: l10n.notificationsMoreLabel,
                    onTap: _openMenu,
                  ),
          ),
        ),
      ),
      if (state.offline)
        SliverPadding(
          padding: sides,
          sliver: SliverToBoxAdapter(
            child: ConnectivityBanner(
              state: .offline,
              title: l10n.notificationsOfflineTitle,
              body: l10n.notificationsOfflineBody,
            ),
          ),
        ),
      if (items.isEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            0,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          sliver: SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: loaded
                  ? EmptyState(
                      title: l10n.notificationsEmptyTitle,
                      icon: Assets.icons.shieldIcon,
                      tone: .mint,
                      body: switch (widget.role) {
                        .patient => l10n.notificationsEmptyBodyPatient,
                        .doctor => l10n.notificationsEmptyBodyDoctor,
                        .pathologist => l10n.notificationsEmptyBodyPathologist,
                      },
                    )
                  : LoadingView(semanticLabel: l10n.notificationsLoadingLabel),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            AppSpacing.md,
            AppSpacing.screenMargin,
            AppSpacing.md,
          ),
          sliver: SliverList.list(children: _groupedRows(context, items)),
        ),
    ];
  }

  List<Widget> _groupedRows(
    BuildContext context,
    List<NotificationModel> items,
  ) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final now = nairobiNow();
    final groups = <_Group, List<NotificationModel>>{
      for (final group in _Group.values) group: [],
    };
    for (final row in items) {
      groups[_groupOf(nairobiTimeOf(row.creationDate), now)]!.add(row);
    }
    final titles = {
      _Group.today: l10n.notificationsToday,
      _Group.yesterday: l10n.notificationsYesterday,
      _Group.earlier: l10n.notificationsEarlier,
    };
    final children = <Widget>[];
    var first = true;
    for (final group in _Group.values) {
      final rows = groups[group]!;
      if (rows.isEmpty) continue;
      if (!first) {
        children.add(const SizedBox(height: AppSpacing.sectionGap));
      }
      first = false;
      children
        ..add(SectionHeader(title: titles[group]!))
        ..add(const SizedBox(height: AppSpacing.sm));
      var firstRow = true;
      for (final row in rows) {
        if (!firstRow) {
          children.add(const SizedBox(height: AppSpacing.sm));
        }
        firstRow = false;
        children.add(
          _row(
            context,
            row,
            _trailingText(nairobiTimeOf(row.creationDate), now, locale),
          ),
        );
      }
    }
    return children;
  }

  Widget _row(
    BuildContext context,
    NotificationModel row,
    String? trailingText,
  ) {
    final l10n = context.l10n;
    final template = NotificationTemplate.fromValue(row.templateKey);
    final title = template.title(l10n, row.templateArgs);
    // The inbox re-renders from the template in the current language; a row
    // whose template the app does not know keeps the server's copy.
    final subtitle = template == NotificationTemplate.unknown
        ? row.message
        : template.body(l10n, row.templateArgs);
    final (icon, tone) = switch (row.categoryValue) {
      .appointment => (Assets.icons.calendarIcon, IconTone.sky),
      .report || .result => (Assets.icons.resultsIcon, IconTone.lavender),
      .preread => (Assets.icons.inProgressIcon, IconTone.lavender),
      .alert => (Assets.icons.infoIcon, IconTone.butter),
      .patientCase => (Assets.icons.testTubeIcon, IconTone.mint),
      .mdt || .message => (Assets.icons.mdtIcon, IconTone.mint),
      .account => (Assets.icons.personIcon, IconTone.sky),
    };
    return ListRowCard(
      leading: IconTile(icon: icon, tone: tone),
      title: title.isEmpty ? row.title : title,
      subtitle: subtitle.isEmpty ? null : subtitle,
      // The code a signed or shared report opens with is for this reader's own
      // eyes: it is shown here and typed on the enter-code screen (T-18). It
      // never goes in a route, a log or a field.
      chip: row.hasShareCode
          ? StatusChip(
              label: l10n.notificationAccessCode(row.metadata.shareCode),
              tone: .info,
            )
          : null,
      trailingText: trailingText,
      unread: !row.isRead,
      chevron: false,
      onTap: () => _onRowTap(row),
    );
  }
}
