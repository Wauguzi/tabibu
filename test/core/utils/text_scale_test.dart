import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/core/utils/text_scale.dart';

void main() {
  Future<double> factorAt(WidgetTester tester, Size size) async {
    late double factor;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: Builder(
          builder: (context) {
            factor = screenAwareTextScaleFactor(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return factor;
  }

  testWidgets('every phone is unscaled, in either orientation', (tester) async {
    expect(await factorAt(tester, const Size(390, 844)), 1);
    expect(await factorAt(tester, const Size(844, 390)), 1);
  });

  testWidgets('a tablet scales up to the cap and no further', (tester) async {
    expect(await factorAt(tester, const Size(684, 1000)), closeTo(1.075, 1e-9));
    expect(await factorAt(tester, const Size(768, 1024)), closeTo(1.15, 1e-9));
    expect(await factorAt(tester, const Size(1024, 1366)), closeTo(1.15, 1e-9));
  });

  test("the person's own scaler is kept, then multiplied", () {
    const base = TextScaler.linear(1.3);
    expect(composedTextScaler(base: base, extraScaleFactor: 1), same(base));
    expect(
      composedTextScaler(base: base, extraScaleFactor: 1.15).scale(10),
      closeTo(14.95, 1e-9),
    );
  });
}
