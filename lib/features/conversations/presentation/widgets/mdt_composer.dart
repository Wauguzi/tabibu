import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// The longest message the conversation layer takes.
const mdtMessageMaxLength = 2000;

/// The consult's text box and send button. A message leaves once: the box
/// empties as it is handed on, so a second tap has nothing to send.
class MdtComposer extends StatefulWidget {
  const MdtComposer({
    required this.hint,
    required this.sendLabel,
    required this.onSend,
    super.key,
  });

  final String hint;
  final String sendLabel;
  final ValueChanged<String> onSend;

  @override
  State<MdtComposer> createState() => _MdtComposerState();
}

class _MdtComposerState extends State<MdtComposer> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasText = _controller.text.trim().isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenMargin,
          AppSpacing.xs,
          AppSpacing.screenMargin,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: .end,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: mdtMessageMaxLength,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: .sentences,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(mdtMessageMaxLength),
                  ],
                  style: textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            CircleIconButton(
              icon: Assets.icons.sendOutlineIcon,
              semanticLabel: widget.sendLabel,
              filled: true,
              onTap: hasText ? _send : null,
            ),
          ],
        ),
      ),
    );
  }
}
