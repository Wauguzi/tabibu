import 'package:flutter/widgets.dart';

/// Shortest sides up to this are phones and are never scaled.
const double _tabletBreakpoint = 600;

/// Where the extra scale reaches [_maxExtraScale]; wider screens are clamped.
const double _referenceTabletWidth = 768;
const double _maxExtraScale = 1.15;

/// The extra type scale for a tablet, from the shortest side so rotating does
/// not change it: 1 on every phone, rising linearly to [_maxExtraScale].
/// Applied in `MaterialApp.builder`, where a window-size change rebuilds it;
/// a bloc or the theme could not react to that.
double screenAwareTextScaleFactor(BuildContext context) {
  final shortestSide = MediaQuery.sizeOf(context).shortestSide;
  if (shortestSide <= _tabletBreakpoint) return 1;
  final progress =
      (shortestSide - _tabletBreakpoint) /
      (_referenceTabletWidth - _tabletBreakpoint);
  return 1 + progress.clamp(0, 1) * (_maxExtraScale - 1);
}

/// A box sized to hold text, scaled with that text so it does not clip on a
/// tablet. Not for padding, icons or radii, which should not grow.
double scaledForText(BuildContext context, double base) =>
    MediaQuery.textScalerOf(context).scale(base);

/// Multiplies the person's own text scaler, keeping its curve (Android 14
/// scales large text less) instead of replacing it with a flat factor.
TextScaler composedTextScaler({
  required TextScaler base,
  required double extraScaleFactor,
}) {
  if (extraScaleFactor == 1) return base;
  return _ComposedTextScaler(base, extraScaleFactor);
}

final class _ComposedTextScaler extends TextScaler {
  const _ComposedTextScaler(this._base, this._extraScaleFactor);

  final TextScaler _base;
  final double _extraScaleFactor;

  @override
  double scale(double fontSize) => _base.scale(fontSize) * _extraScaleFactor;

  @override
  double get textScaleFactor => scale(1);

  @override
  bool operator ==(Object other) =>
      other is _ComposedTextScaler &&
      other._base == _base &&
      other._extraScaleFactor == _extraScaleFactor;

  @override
  int get hashCode => Object.hash(_base, _extraScaleFactor);
}
