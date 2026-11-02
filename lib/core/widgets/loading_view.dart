import 'package:material_ui/material_ui.dart';

/// A centred loading spinner with its announcement.
class LoadingView extends StatelessWidget {
  const LoadingView({required this.semanticLabel, super.key});

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
        ),
      ),
    );
  }
}
