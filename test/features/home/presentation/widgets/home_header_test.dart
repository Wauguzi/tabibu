import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/circle_icon_button.dart';
import 'package:tabibu/features/home/presentation/widgets/home_header.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('HomeHeader', () {
    HomeHeader header({VoidCallback? onNotifications, bool hasUnread = false}) {
      return HomeHeader(
        name: 'Amina Wambui',
        greeting: 'Habari, Amina',
        subtitle: 'Embakasi · Tue 27 Oct',
        notificationsLabel: 'Notifications',
        onNotifications: onNotifications,
        hasUnread: hasUnread,
      );
    }

    Finder unreadDot(ColorScheme scheme) => find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == scheme.error,
    );

    ColorScheme schemeOf(WidgetTester tester) =>
        Theme.of(tester.element(find.byType(HomeHeader))).colorScheme;

    testWidgets('renders the greeting with its bell', (tester) async {
      await tester.pumpApp(header());
      await tester.pumpAndSettle();

      expect(find.text('Habari, Amina'), findsOneWidget);
      expect(find.text('Embakasi · Tue 27 Oct'), findsOneWidget);
      final bell = tester.widget<CircleIconButton>(
        find.byType(CircleIconButton),
      );
      expect(bell.semanticLabel, 'Notifications');
      expect(bell.onTap, isNull);
      expect(unreadDot(schemeOf(tester)), findsNothing);
    });

    testWidgets('opens notifications from the bell', (tester) async {
      var taps = 0;
      await tester.pumpApp(header(onNotifications: () => taps++));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CircleIconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('shows the unread dot only when hasUnread', (tester) async {
      await tester.pumpApp(header());
      await tester.pumpAndSettle();
      expect(unreadDot(schemeOf(tester)), findsNothing);

      await tester.pumpApp(header(hasUnread: true, onNotifications: () {}));
      await tester.pumpAndSettle();
      final scheme = schemeOf(tester);
      expect(unreadDot(scheme), findsOneWidget);
      expect(tester.getSize(unreadDot(scheme)), const Size(10, 10));
      final dot = tester.widget<Container>(unreadDot(scheme));
      final decoration = dot.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.border?.top.color, scheme.surfaceContainerLowest);
      expect(decoration.border?.top.width, 2);
    });

    testWidgets('says unread in the bell label only when hasUnread', (
      tester,
    ) async {
      await tester.pumpApp(header());
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(CircleIconButton)),
        matchesSemantics(label: 'Notifications', isButton: true),
      );

      await tester.pumpApp(header(hasUnread: true, onNotifications: () {}));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(CircleIconButton)),
        matchesSemantics(
          label: 'Notifications, unread',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('renders in dark', (tester) async {
      await tester.pumpApp(
        header(hasUnread: true, onNotifications: () {}),
        themeMode: ThemeMode.dark,
      );
      await tester.pumpAndSettle();

      expect(find.text('Habari, Amina'), findsOneWidget);
      expect(unreadDot(schemeOf(tester)), findsOneWidget);
    });

    testWidgets('renders in Swahili', (tester) async {
      await tester.pumpApp(header(), locale: const Locale('sw'));
      await tester.pumpAndSettle();

      expect(find.text('Habari, Amina'), findsOneWidget);
    });

    testWidgets('grows at 1.3x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(header(hasUnread: true, onNotifications: () {}));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
