import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

extension KeyboardTester on WidgetTester {
  /// Tabs until [finder]'s widget has focus, checking after each Tab rather
  /// than counting them, so a screen's tab order can change without breaking
  /// the test.
  Future<void> tabTo(Finder finder) async {
    for (var i = 0; i < 8; i++) {
      await sendKeyEvent(LogicalKeyboardKey.tab);
      await pump();
      if (Focus.of(element(finder)).hasFocus) return;
    }
    fail('never reached $finder');
  }
}
