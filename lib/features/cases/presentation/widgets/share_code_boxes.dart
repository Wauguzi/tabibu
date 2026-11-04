import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';

const int shareCodeLength = 4;

/// The code as four read-only tiles. Shown only while the bloc holds a
/// revealed code (T-18); nothing here stores it.
class ShareCodeDigits extends StatelessWidget {
  const ShareCodeDigits({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: code.split('').join(' '),
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: .center,
          children: [
            for (var i = 0; i < shareCodeLength; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              _CodeBox(digit: i < code.length ? code[i] : '', active: false),
            ],
          ],
        ),
      ),
    );
  }
}

/// Four boxes over one invisible digits-only field, so the keyboard, paste
/// and the screen reader all see an ordinary text field. Never prefilled and
/// never offered an autofill value (T-18).
class ShareCodeField extends StatefulWidget {
  const ShareCodeField({
    required this.controller,
    required this.label,
    this.onChanged,
    this.hasError = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  State<ShareCodeField> createState() => _ShareCodeFieldState();
}

class _ShareCodeFieldState extends State<ShareCodeField> {
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.controller, _focus]),
      builder: (context, _) {
        final code = widget.controller.text;
        return Stack(
          children: [
            ExcludeSemantics(
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  for (var i = 0; i < shareCodeLength; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm),
                    _CodeBox(
                      digit: i < code.length ? code[i] : '',
                      active:
                          _focus.hasFocus &&
                          i == code.length.clamp(0, shareCodeLength - 1),
                      hasError: widget.hasError,
                    ),
                  ],
                ],
              ),
            ),
            Positioned.fill(
              child: Semantics(
                label: widget.label,
                textField: true,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  keyboardType: .number,
                  autocorrect: false,
                  enableSuggestions: false,
                  enableInteractiveSelection: false,
                  showCursor: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(shareCodeLength),
                  ],
                  style: const TextStyle(color: AppColors.transparent),
                  decoration: const InputDecoration.collapsed(hintText: null),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.digit,
    required this.active,
    this.hasError = false,
  });

  final String digit;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == .dark;
    final border = hasError
        ? scheme.error
        : active
        ? scheme.primary
        : scheme.outlineVariant;
    return Container(
      width: 64,
      height: 72,
      alignment: .center,
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.field),
        border: Border.all(color: border, width: active || hasError ? 2 : 1),
      ),
      child: Text(digit, style: Theme.of(context).textTheme.headlineMedium),
    );
  }
}
