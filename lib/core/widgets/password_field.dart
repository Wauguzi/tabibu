import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';
import 'package:tabibu/core/widgets/tabibu_text_field.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// A password field: lock leading icon, hidden text, and an eye toggle
/// that announces the action it will take.
class PasswordField extends StatefulWidget {
  const PasswordField({
    required this.label,
    required this.showLabel,
    required this.hideLabel,
    this.hint,
    this.controller,
    this.errorText,
    this.helperText,
    this.required = false,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final String showLabel;
  final String hideLabel;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final String? helperText;
  final bool required;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  void _toggle() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    return TabibuTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      leading: AssetIcon(Assets.icons.passwordIcon, size: 22, scaleUp: false),
      trailing: Semantics(
        label: _obscured ? widget.showLabel : widget.hideLabel,
        button: true,
        onTap: _toggle,
        excludeSemantics: true,
        child: SizedBox(
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: _toggle,
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: AssetIcon(
                _obscured
                    ? Assets.icons.passwordVisibleIcon
                    : Assets.icons.passwordHiddenIcon,
                size: 22,
              ),
            ),
          ),
        ),
      ),
      mergeSemantics: false,
      errorText: widget.errorText,
      helperText: widget.helperText,
      required: widget.required,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: _obscured,
    );
  }
}
