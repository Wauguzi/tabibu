import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/asset_icon.dart';

/// A labeled text field: label with an optional red asterisk, white rounded
/// input with teal focus and red error borders, and helper or error text
/// below. Multiline fields take a character limit shown as `n / max`.
class TabibuTextField extends StatefulWidget {
  const TabibuTextField({
    required this.label,
    this.hint,
    this.controller,
    this.leading,
    this.trailing,
    this.errorText,
    this.helperText,
    this.required = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.autofillHints,
    this.mergeSemantics = true,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final Widget? leading;
  final Widget? trailing;
  final String? errorText;
  final String? helperText;
  final bool required;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  /// Shows a value that can no longer change, muted, as an email once its
  /// account exists.
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Iterable<String>? autofillHints;

  /// Whether the label and field merge into one semantics node. Stays true
  /// unless the trailing carries its own button, which cannot live under a
  /// merge: the password toggle needs a separate node.
  final bool mergeSemantics;

  @override
  State<TabibuTextField> createState() => _TabibuTextFieldState();
}

class _TabibuTextFieldState extends State<TabibuTextField> {
  TextEditingController? _ownedController;

  // Focus colours the icons and the cursor like the focused border.
  late final FocusNode _focus = FocusNode()..addListener(() => setState(() {}));

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());

  @override
  void dispose() {
    _focus.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasError = widget.errorText != null;
    final accent = hasError ? scheme.error : scheme.primary;
    // At rest the icons keep the shade they have always shown.
    final iconColor = _focus.hasFocus && !widget.readOnly
        ? accent
        : scheme.onSurface;
    final radius = BorderRadius.circular(AppRadii.field);

    final maxLength = widget.maxLength;
    final field = TextField(
      controller: _controller,
      focusNode: _focus,
      cursorColor: accent,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: widget.maxLines,
      maxLength: maxLength,
      obscureText: widget.obscureText,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      style: widget.readOnly
          ? textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)
          : textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        errorText: widget.errorText,
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        errorMaxLines: 3,
        counterText: '',
        filled: true,
        fillColor: widget.readOnly
            ? scheme.surfaceContainerLow
            : scheme.surfaceContainerLowest,
        contentPadding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          widget.maxLength == null ? AppSpacing.md : AppSpacing.xlg,
        ),
        prefixIcon: widget.leading == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: _tinted(widget.leading!, iconColor),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 54),
        suffixIcon: _suffixIcon(scheme, maxLength, iconColor),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
    );

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            style: textTheme.titleMedium,
            children: [
              if (widget.required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: scheme.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        field,
        if (!hasError && widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(widget.helperText!, style: textTheme.bodySmall),
        ],
      ],
    );
    if (!widget.mergeSemantics) return column;
    return MergeSemantics(child: column);
  }

  /// The trailing slot: the counter lives here so the decorator keeps it
  /// inside the input box, clear of the error and helper lines below. A
  /// caller trailing shares the slot from the top.
  Widget? _suffixIcon(ColorScheme scheme, int? maxLength, Color iconColor) {
    final trailing = widget.trailing;
    if (trailing == null && maxLength == null) return null;
    if (maxLength == null) {
      return Padding(
        padding: const EdgeInsets.only(right: AppSpacing.xs),
        child: _tinted(trailing!, iconColor),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Column(
        mainAxisAlignment: trailing == null
            ? MainAxisAlignment.end
            : MainAxisAlignment.spaceBetween,
        children: [
          if (trailing != null) _tinted(trailing, iconColor),
          ExcludeSemantics(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) => Text(
                '${value.text.length} / $maxLength',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tinted(Widget icon, Color color) => IconTheme(
    data: IconThemeData(color: color, size: 22),
    child: FieldIconTint(color: color, child: icon),
  );
}
