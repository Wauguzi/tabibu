import 'package:tabibu/app/app.dart';
import 'package:tabibu/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
