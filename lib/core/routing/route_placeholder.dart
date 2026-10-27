import 'package:material_ui/material_ui.dart';

/// Stands in for a screen that is routed but not built yet, so the route
/// tree, the guard and the decision route can be tested ahead of the screens.
class RoutePlaceholder extends StatelessWidget {
  const RoutePlaceholder({required this.name, super.key});

  /// The design's screen id, e.g. `B1 Sign in`.
  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(name)),
    );
  }
}
