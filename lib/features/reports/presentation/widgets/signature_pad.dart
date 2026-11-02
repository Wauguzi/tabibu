import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/app_status_colors.dart';
import 'package:tabibu/core/widgets/widgets.dart';

/// In-memory strokes for [SignaturePad]. Nothing is written to disk.
class SignaturePadController extends ChangeNotifier {
  _SignaturePadState? _state;

  bool get isEmpty => _state?._isEmpty ?? true;

  void clear() => _state?._clear();

  /// Base64 PNG at 3× the pad's logical size, ink on transparent, or null
  /// when empty. Width must satisfy `checkedSignature` (≥ 300 px).
  Future<String?> toPngBase64() {
    final state = _state;
    if (state == null) return Future<String?>.value();
    return state._toPngBase64();
  }

  // Bind/unbind the live pad; not a field setter.
  // ignore: use_setters_to_change_properties
  void _attach(_SignaturePadState state) {
    _state = state;
  }

  void _detach(_SignaturePadState state) {
    if (identical(_state, state)) _state = null;
  }

  void _tick() => notifyListeners();
}

/// Signing surface: pan strokes, Clear once drawn, PNG export for signReport.
class SignaturePad extends StatefulWidget {
  const SignaturePad({
    required this.controller,
    required this.hint,
    required this.clearLabel,
    required this.semanticLabel,
    this.height = 160,
    super.key,
  });

  final SignaturePadController controller;
  final String hint;
  final String clearLabel;
  final String semanticLabel;
  final double height;

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  final GlobalKey _boundaryKey = GlobalKey();
  final List<List<Offset>> _strokes = [];
  List<Offset>? _active;

  static const double _strokeWidth = 2.5;

  bool get _isEmpty => _strokes.isEmpty && _active == null;

  @override
  void initState() {
    super.initState();
    widget.controller._attach(this);
  }

  @override
  void didUpdateWidget(SignaturePad oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach(this);
      widget.controller._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    super.dispose();
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _active = null;
    });
    widget.controller._tick();
  }

  Future<String?> _toPngBase64() async {
    if (_isEmpty) return null;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null || !boundary.attached) return null;
    final image = await boundary.toImage(
      pixelRatio: signaturePixelRatio(boundary.size),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) return null;
    return base64Encode(bytes.buffer.asUint8List());
  }

  void _start(Offset local, Size size) {
    if (!_inside(local, size)) return;
    setState(() => _active = [local]);
    widget.controller._tick();
  }

  void _update(Offset local, Size size) {
    final active = _active;
    if (active == null || !_inside(local, size)) return;
    setState(() => active.add(local));
  }

  void _end() {
    final active = _active;
    if (active == null) return;
    setState(() {
      if (active.length >= 2) {
        _strokes.add(List<Offset>.from(active));
      }
      _active = null;
    });
    widget.controller._tick();
  }

  bool _inside(Offset local, Size size) =>
      local.dx >= 0 &&
      local.dy >= 0 &&
      local.dx <= size.width &&
      local.dy <= size.height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = Theme.of(context).extension<AppStatusColors>()!;
    final textTheme = Theme.of(context).textTheme;
    final empty = _isEmpty;

    return Column(
      crossAxisAlignment: .stretch,
      mainAxisSize: .min,
      children: [
        Semantics(
          label: widget.semanticLabel,
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppRadii.field),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.field),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return Stack(
                      fit: .expand,
                      children: [
                        // Baseline rule.
                        Positioned(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          bottom: widget.height * 0.28,
                          child: CustomPaint(
                            painter: _BaselinePainter(
                              color: scheme.outlineVariant,
                            ),
                            size: Size(constraints.maxWidth, 1),
                          ),
                        ),
                        if (empty)
                          Center(
                            child: Text(
                              widget.hint,
                              style: textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        Positioned.fill(
                          child: RepaintBoundary(
                            key: _boundaryKey,
                            child: CustomPaint(
                              painter: _SignaturePainter(
                                strokes: [..._strokes, ?_active],
                                color: status.ink,
                                strokeWidth: _strokeWidth,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: .opaque,
                            onPanStart: (d) => _start(d.localPosition, size),
                            onPanUpdate: (d) => _update(d.localPosition, size),
                            onPanEnd: (_) => _end(),
                            onPanCancel: _end,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        if (!empty) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: .centerRight,
            child: TabibuButton.ghost(label: widget.clearLabel, onTap: _clear),
          ),
        ],
      ],
    );
  }
}

class _BaselinePainter extends CustomPainter {
  _BaselinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      Paint()
        ..color = color
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_BaselinePainter oldDelegate) =>
      oldDelegate.color != color;
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({
    required this.strokes,
    required this.color,
    required this.strokeWidth,
  });

  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = .stroke
      ..strokeCap = .round
      ..strokeJoin = .round
      ..isAntiAlias = true;

    for (final stroke in strokes) {
      if (stroke.length < 2) {
        if (stroke.length == 1) {
          canvas.drawPoints(ui.PointMode.points, stroke, paint);
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        final prev = stroke[i - 1];
        final curr = stroke[i];
        final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
      path.lineTo(stroke.last.dx, stroke.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) =>
      oldDelegate.strokes != strokes ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// The export scale: 3x where it fits, held inside what `signReport`
/// accepts (`checkedSignature`: 300 to 2000 px wide, at most 2000 tall), so
/// a tablet-wide pad never yields a signature the server refuses.
double signaturePixelRatio(Size size) {
  if (size.width <= 0 || size.height <= 0) return 3;
  final ceiling = math.min(2000 / size.width, 2000 / size.height);
  return math.max(math.min(3, ceiling), 300 / size.width);
}
