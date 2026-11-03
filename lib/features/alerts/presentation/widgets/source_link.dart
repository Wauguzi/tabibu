import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/alerts/data/models/guidance_source_model.dart';
import 'package:tabibu/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// A source's title as a link to the document (design system §4.5). Shared
/// by the MoH protocol screen and the patient's health notice.
class SourceLink extends StatelessWidget {
  const SourceLink({required this.source, super.key});

  final GuidanceSourceModel source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final uri = Uri.tryParse(source.url);
    final label = context.l10n.mohSource(source.title);
    return Semantics(
      link: true,
      label: label,
      excludeSemantics: true,
      child: Tappable(
        onTap: uri == null ? null : () => unawaited(launchUrl(uri)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
