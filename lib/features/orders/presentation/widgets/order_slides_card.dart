import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_shadows.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_item.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_bloc.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_event.dart';
import 'package:tabibu/features/cases/blocs/slide_upload_bloc/slide_upload_state.dart';
import 'package:tabibu/features/cases/data/datasources/slide_storage.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// Step 3 slides (F-12): the file rows for a case that needs them, each with
/// its pixel size, Add slides, Upload and a Retry on a failed row. The rows
/// live in [SlideUploadBloc]; a partial upload ends in success with some rows
/// still failed, and those keep their Retry.
class OrderSlidesCard extends StatefulWidget {
  const OrderSlidesCard({
    required this.caseUid,
    required this.doctorUid,
    super.key,
  });

  final String caseUid;
  final String doctorUid;

  @override
  State<OrderSlidesCard> createState() => _OrderSlidesCardState();
}

class _OrderSlidesCardState extends State<OrderSlidesCard> {
  bool _picking = false;
  AppError? _pickError;

  SlideUploadBloc get _bloc => context.read<SlideUploadBloc>();

  @override
  void initState() {
    super.initState();
    _dropForeignCase();
  }

  @override
  void didUpdateWidget(OrderSlidesCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.caseUid != widget.caseUid) _dropForeignCase();
  }

  /// The bloc holds one case's rows. Rows from another case are dropped
  /// before they can be read or sent here, unless their upload is running.
  void _dropForeignCase() {
    final upload = _bloc.state;
    if (upload is SlideUploadInProgress) return;
    if (upload.caseUid.isNotEmpty && upload.caseUid != widget.caseUid) {
      _bloc.add(const SlideUploadReset());
    }
  }

  Future<void> _pick() async {
    setState(() {
      _picking = true;
      _pickError = null;
    });
    try {
      final files = await getIt<FilePickerService>().pickSlides();
      if (!mounted) return;
      if (files.isEmpty) return;
      _bloc.add(
        SlidesPicked(
          picks: [
            for (final file in files)
              SlidePick(
                bytes: file.bytes,
                fileName: file.name,
                contentType: file.contentType,
              ),
          ],
        ),
      );
    } on AppError catch (error) {
      if (!mounted) return;
      setState(() => _pickError = error);
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _pickError = AppError.unknown);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _request() => _bloc.add(
    SlideUploadRequested(uid: widget.doctorUid, caseUid: widget.caseUid),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final upload = context.watch<SlideUploadBloc>().state;
    final foreign =
        upload.caseUid.isNotEmpty && upload.caseUid != widget.caseUid;
    final slides = foreign ? const <SlideItem>[] : upload.slides;
    final busy = upload is SlideUploadInProgress;
    final canUpload =
        !foreign &&
        !busy &&
        slides.any(
          (s) =>
              s.status == SlideUploadStatus.picked ||
              s.status == SlideUploadStatus.failed,
        );
    final failure = upload is SlideUploadFailure && !foreign
        ? upload.error
        : null;
    final error = _pickError ?? failure;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        SectionHeader(title: l10n.orderSlidesTitle),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.orderSlidesBody, style: textTheme.bodyMedium),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            error.description(l10n),
            style: textTheme.bodyMedium?.copyWith(color: scheme.error),
          ),
        ],
        for (final slide in slides) ...[
          const SizedBox(height: AppSpacing.sm),
          _SlideRow(
            key: ValueKey(slide.localId),
            slide: slide,
            onRemove: () => _bloc.add(SlideRemoved(localId: slide.localId)),
            onPixelSize: (value) => _bloc.add(
              SlidePixelSizeSet(localId: slide.localId, micronsPerPixel: value),
            ),
            onRetry: _request,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        TabibuButton.outline(
          label: l10n.orderSlidesAdd,
          isLoading: _picking,
          onTap: foreign || busy ? null : _pick,
        ),
        const SizedBox(height: AppSpacing.xs),
        TabibuButton.primary(
          label: l10n.orderSlidesUpload,
          isLoading: busy && !foreign,
          onTap: canUpload ? _request : null,
        ),
      ],
    );
  }
}

/// One picked slide: the file, its state, its pixel size and, when it
/// failed, a Retry. A pixel size is sent only once it parses and lies in
/// the bloc's range; anything else is a field error.
class _SlideRow extends StatefulWidget {
  const _SlideRow({
    required this.slide,
    required this.onRemove,
    required this.onPixelSize,
    required this.onRetry,
    super.key,
  });

  final SlideItem slide;
  final VoidCallback onRemove;
  final ValueChanged<double> onPixelSize;
  final VoidCallback onRetry;

  @override
  State<_SlideRow> createState() => _SlideRowState();
}

class _SlideRowState extends State<_SlideRow> {
  late final TextEditingController _pixels;
  bool _invalid = false;

  @override
  void initState() {
    super.initState();
    _pixels = TextEditingController(text: _textOf(widget.slide));
  }

  @override
  void didUpdateWidget(_SlideRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only a new size from the bloc replaces text; an upload patch must
    // never wipe a half-typed value.
    if (oldWidget.slide.micronsPerPixel != widget.slide.micronsPerPixel) {
      _pixels.text = _textOf(widget.slide);
    }
    if (oldWidget.slide.status != widget.slide.status) _invalid = false;
  }

  @override
  void dispose() {
    _pixels.dispose();
    super.dispose();
  }

  static String _textOf(SlideItem slide) {
    final value = slide.micronsPerPixel;
    return value == null ? '' : '$value';
  }

  void _sized(String text) {
    final value = double.tryParse(text.trim());
    final valid = value != null && value.isFinite && value > 0 && value <= 100;
    if (text.trim().isEmpty) {
      setState(() => _invalid = false);
      return;
    }
    if (!valid) {
      setState(() => _invalid = true);
      return;
    }
    setState(() => _invalid = false);
    widget.onPixelSize(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final slide = widget.slide;
    final size = formatFileSize(slide.bytes.length);
    final meta = slide.contentType == SlideStorage.png
        ? l10n.orderSlidesMetaPng(size)
        : l10n.orderSlidesMetaJpeg(size);
    final failed = slide.status == SlideUploadStatus.failed;
    final removable = slide.status == SlideUploadStatus.picked || failed;

    final isDark = scheme.brightness == .dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? scheme.surfaceContainerHigh
            : scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              IconTile(icon: Assets.icons.documentIcon, tone: .mint),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(
                      slide.fileName,
                      style: textTheme.titleSmall,
                      maxLines: 1,
                      overflow: .ellipsis,
                    ),
                    Text(meta, style: textTheme.bodySmall),
                    _SlideStatus(slide: slide),
                  ],
                ),
              ),
              if (removable) ...[
                const SizedBox(width: AppSpacing.sm),
                CircleIconButton(
                  icon: Assets.icons.deleteIcon,
                  onCard: true,
                  semanticLabel: l10n.orderSlidesRemove(slide.fileName),
                  onTap: widget.onRemove,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TabibuTextField(
            label: l10n.orderSlidesPixelSizeLabel,
            hint: l10n.orderSlidesPixelSizeHint,
            controller: _pixels,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: _invalid ? l10n.orderSlidesPixelSizeInvalid : null,
            readOnly: slide.isSettled,
            onChanged: _sized,
          ),
          if (failed) ...[
            const SizedBox(height: AppSpacing.sm),
            TabibuButton.outline(
              label: l10n.commonRetry,
              onTap: widget.onRetry,
            ),
          ],
        ],
      ),
    );
  }
}

/// What a row says under its size line. Picked rows say nothing; failed
/// rows say the failure in the person's language.
class _SlideStatus extends StatelessWidget {
  const _SlideStatus({required this.slide});

  final SlideItem slide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    switch (slide.status) {
      case SlideUploadStatus.picked:
        return const SizedBox.shrink();
      case SlideUploadStatus.uploading:
        return Row(
          mainAxisSize: .min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(l10n.orderSlidesUploading, style: textTheme.bodySmall),
          ],
        );
      case SlideUploadStatus.uploaded:
        return Row(
          mainAxisSize: .min,
          children: [
            AssetIcon(Assets.icons.checkCircleIcon, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Text(l10n.orderSlidesUploaded, style: textTheme.bodySmall),
          ],
        );
      case SlideUploadStatus.failed:
        // A row sized after failing has no error left; only Retry speaks.
        final error = slide.error;
        if (error == null) return const SizedBox.shrink();
        return Text(
          error.description(l10n),
          style: textTheme.bodySmall?.copyWith(color: scheme.error),
        );
    }
  }
}
