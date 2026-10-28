import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/dashed_border.dart';
import 'package:tabibu/core/widgets/notice_card.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../helpers/helpers.dart';

void main() {
  group('NoticeCard', () {
    testWidgets('renders every variant', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(
          child: Column(
            children: [
              for (final variant in NoticeVariant.values)
                NoticeCard(
                  icon: switch (variant) {
                    NoticeVariant.aiDraft || NoticeVariant.signed => null,
                    _ => Assets.icons.infoIcon,
                  },
                  title: 'Title $variant',
                  body: 'Body $variant',
                  variant: variant,
                ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (final variant in NoticeVariant.values) {
        expect(find.text('Title $variant'), findsOneWidget);
        expect(find.text('Body $variant'), findsOneWidget);
      }
    });

    testWidgets('frames the draft dashed with the draft icon', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const NoticeCard(
            title: 'Draft title',
            body: 'Draft body',
            variant: NoticeVariant.aiDraft,
          ),
          themeMode: mode,
        );
        await tester.pumpAndSettle();

        final frame = tester.widget<DashedBorder>(find.byType(DashedBorder));
        final status = Theme.of(
          tester.element(find.byType(NoticeCard)),
        ).extension<AppStatusColors>()!;
        expect(frame.color, status.draftBorder);

        final icon = tester.widget<AssetIcon>(find.byType(AssetIcon));
        expect(icon.asset, Assets.icons.inProgressIcon);
      }
    });

    testWidgets('signs with the badge and no frame', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpApp(
          const NoticeCard(
            title: 'Signed title',
            body: 'Signed body',
            variant: NoticeVariant.signed,
          ),
          themeMode: mode,
        );
        await tester.pumpAndSettle();

        expect(find.byType(DashedBorder), findsNothing);
        final icon = tester.widget<AssetIcon>(find.byType(AssetIcon));
        expect(icon.asset, Assets.icons.verificationBadge);
      }
    });

    testWidgets('leads with the body when untitled', (tester) async {
      await tester.pumpApp(
        NoticeCard(
          icon: Assets.icons.infoIcon,
          body: 'Body only',
          variant: NoticeVariant.info,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Body only'), findsOneWidget);
    });

    testWidgets('grows at 2.0x text without overflow', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpApp(
        SingleChildScrollView(
          child: NoticeCard(
            icon: Assets.icons.infoIcon,
            title: 'A long title that must wrap, not clip',
            body: 'A long body that must also wrap onto more lines',
            variant: NoticeVariant.attention,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
