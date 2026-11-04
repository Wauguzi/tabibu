import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// A [TabibuBottomSheet] whose result arrives once the sheet has slid away.
/// The pop resolves while the sheet is still moving; an action taken then
/// (a release, an approval) would change the screen under a half-closed
/// sheet.
Future<T?> showSettledSheet<T>(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext sheet) builder,
  String? subtitle,
  String? cancelLabel,
  Widget? leading,
}) async {
  ModalRoute<T>? route;
  final result = await TabibuBottomSheet.show<T>(
    context,
    title: title,
    subtitle: subtitle,
    cancelLabel: cancelLabel,
    leading: leading,
    builder: (sheet) {
      route = ModalRoute.of(sheet) as ModalRoute<T>?;
      return builder(sheet);
    },
  );
  await _closed(route?.animation);
  return result;
}

Future<void> _closed(Animation<double>? animation) {
  if (animation == null || animation.isDismissed) return Future.value();
  final done = Completer<void>();
  void listener(AnimationStatus status) {
    if (status != .dismissed) return;
    animation.removeStatusListener(listener);
    done.complete();
  }

  animation.addStatusListener(listener);
  return done.future;
}
