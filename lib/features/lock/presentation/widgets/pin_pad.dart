import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/lock/data/lock_storage.dart';
import 'package:tabibu/gen/assets.gen.dart';

/// Four empty / filled dots for the digits typed so far.
class PinDots extends StatelessWidget {
  const PinDots({required this.length, this.hasError = false, super.key});

  final int length;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = hasError ? scheme.error : scheme.onSurface;
    return Semantics(
      label: '$length of ${LockStorage.pinLength}',
      child: Row(
        mainAxisAlignment: .center,
        children: [
          for (var i = 0; i < LockStorage.pinLength; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: .circle,
                color: i < length ? fill : null,
                border: Border.all(color: fill.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A 3×4 digit pad. Digits append until four; backspace clears the last.
class PinPad extends StatelessWidget {
  const PinPad({
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: [
        for (final row in keys) ...[
          Row(
            mainAxisAlignment: .center,
            children: [
              for (final key in row) ...[
                _Key(
                  label: key,
                  enabled: enabled && key.isNotEmpty,
                  onTap: key == '⌫'
                      ? onBackspace
                      : key.isEmpty
                      ? null
                      : () => onDigit(key),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.enabled, this.onTap});

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (label.isEmpty) {
      return const SizedBox(width: 72, height: 72);
    }
    final child = label == '⌫'
        ? AssetIcon(Assets.icons.backIcon, size: 22, color: scheme.onSurface)
        : Text(label, style: textTheme.headlineSmall);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label == '⌫' ? 'Backspace' : label,
        child: Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: SizedBox(width: 72, height: 72, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}

/// Collects four digits then calls [onComplete] once. Clears itself after.
class PinEntry extends StatefulWidget {
  const PinEntry({
    required this.onComplete,
    this.enabled = true,
    this.hasError = false,
    this.errorLabel,
    super.key,
  });

  final ValueChanged<String> onComplete;
  final bool enabled;
  final bool hasError;
  final String? errorLabel;

  @override
  State<PinEntry> createState() => _PinEntryState();
}

class _PinEntryState extends State<PinEntry> {
  String _pin = '';

  void _digit(String d) {
    if (!widget.enabled || _pin.length >= LockStorage.pinLength) return;
    setState(() => _pin += d);
    if (_pin.length == LockStorage.pinLength) {
      final done = _pin;
      widget.onComplete(done);
      // Clear after the frame so a mismatch can show empty dots again.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _pin = '');
      });
    }
  }

  void _back() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorLabel;
    return Column(
      children: [
        PinDots(length: _pin.length, hasError: widget.hasError),
        if (error != null && error.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: .center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        PinPad(enabled: widget.enabled, onDigit: _digit, onBackspace: _back),
      ],
    );
  }
}
