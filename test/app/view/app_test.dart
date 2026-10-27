import 'package:flutter_test/flutter_test.dart';
import 'package:tabibu/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders the placeholder home', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('Tabibu'), findsOneWidget);
    });
  });
}
