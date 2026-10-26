import 'package:material_ui/material_ui.dart';
import 'package:tabibu/app/app.dart';
import 'package:tabibu/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(() => const App());
}
