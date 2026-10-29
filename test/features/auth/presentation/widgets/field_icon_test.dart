import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/gen/assets.gen.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('FieldIcon', () {
    testWidgets('keeps the 22 px slot and the glyph at drawn size', (
      tester,
    ) async {
      await tester.pumpApp(FieldIcon(Assets.icons.personIcon));
      await tester.pumpAndSettle();

      // The slot keeps field text where it was.
      expect(tester.getSize(find.byType(FieldIcon)), const Size(22, 22));

      // scaleUp false keeps the glyph at its drawn size; personIcon
      // draws at 13x18, so it sits centred and unscaled in the slot.
      expect(tester.widget<AssetIcon>(find.byType(AssetIcon)).scaleUp, isFalse);
      expect(tester.getSize(find.byType(SvgPicture)), const Size(13, 18));
    });
  });
}
