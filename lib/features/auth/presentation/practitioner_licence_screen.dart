import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/widgets/document_sheet.dart';
import 'package:tabibu/features/auth/presentation/widgets/draft_pop_scope.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/picker_field.dart';
import 'package:tabibu/features/auth/presentation/widgets/specialty_sheet.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// E2 and F2. The KMPDC number, the specialties (doctors, up to five) or
/// areas (pathologists), and one or two licence files. Nothing is uploaded
/// here; the auth bloc uploads on submit.
class PractitionerLicenceScreen extends StatefulWidget {
  const PractitionerLicenceScreen({super.key});

  @override
  State<PractitionerLicenceScreen> createState() =>
      _PractitionerLicenceScreenState();
}

class _PractitionerLicenceScreenState extends State<PractitionerLicenceScreen> {
  late final TextEditingController _kmpdcController;
  List<Specialty> _specialties = [];
  List<UploadFile> _licenses = [];
  AppError? _error;
  bool _readingLicence = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<SignUpBloc>().state.draft;
    _kmpdcController = TextEditingController(text: draft.kmpdcNumber);
    _specialties = List.of(draft.specialties);
    _licenses = List.of(draft.licenses);
  }

  @override
  void dispose() {
    _kmpdcController.dispose();
    super.dispose();
  }

  bool get _isPathologist =>
      context.read<SignUpBloc>().state.draft.role == .pathologist;

  Future<void> _pickSpecialties() async {
    final l10n = context.l10n;
    final isPathologist = _isPathologist;
    final picked = await showSpecialtySheet(
      context: context,
      title: isPathologist ? l10n.areasLabel : l10n.specialtySheetTitle,
      subtitle: (count) => isPathologist
          ? l10n.areasSheetSubtitle(count)
          : l10n.specialtySheetSubtitle(count),
      searchHint: isPathologist
          ? l10n.areasSearchHint
          : l10n.specialtySearchHint,
      doneLabel: l10n.specialtyDone,
      initial: _specialties,
      allowed: Specialty.forRole(isPathologist: isPathologist),
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _specialties = picked;
      _error = null;
    });
  }

  Future<void> _addDocument() async {
    final l10n = context.l10n;
    final source = await showDocumentSheet(
      context,
      subtitle: _isPathologist
          ? l10n.documentSheetPathologistSubtitle
          : l10n.documentSheetSubtitle,
    );
    if (source == null || !mounted) return;
    setState(() => _readingLicence = true);
    try {
      final file = source == DocumentSource.camera
          // A photographed page is a photo; the service downsizes it well
          // under the licence limit.
          ? await getIt<FilePickerService>().pickPhoto(fromCamera: true)
          : await getIt<FilePickerService>().pickLicence();
      if (!mounted) return;
      if (file == null) return;
      setState(() {
        _licenses = [..._licenses, file];
        _error = null;
      });
    } on AppError catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    } on Object catch (_) {
      if (!mounted) return;
      setState(() => _error = AppError.unknown);
    } finally {
      if (mounted) setState(() => _readingLicence = false);
    }
  }

  SignUpDraft _fill(SignUpDraft draft) => draft.copyWith(
    kmpdcNumber: _kmpdcController.text.trim(),
    specialties: _specialties,
    licenses: _licenses,
  );

  void _continue() {
    final allowed = Specialty.forRole(isPathologist: _isPathologist);
    final AppError? error;
    if (_kmpdcController.text.trim().isEmpty) {
      error = AppError.invalidKmpdcNumber;
    } else if (_specialties.isEmpty ||
        _specialties.length > Specialty.maxSelected ||
        !_specialties.every(allowed.contains)) {
      error = AppError.invalidSpecialties;
    } else if (_licenses.isEmpty || _licenses.length > 2) {
      error = AppError.invalidLicense;
    } else {
      error = null;
    }
    setState(() => _error = error);
    if (error != null) return;

    final draft = _fill(context.read<SignUpBloc>().state.draft);
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: draft));
    unawaited(const PractitionerFacilityRoute().push<void>(context));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final role = context.watch<SignUpBloc>().state.draft.role;
    final isPathologist = role == .pathologist;

    return DraftPopScope(
      fill: _fill,
      child: StepScaffold(
        step: 2,
        total: 4,
        backLabel: l10n.commonBack,
        onBack: () => Navigator.of(context).pop(),
        title: isPathologist ? l10n.areasTitle : l10n.licenceTitle,
        subtitle: isPathologist
            ? l10n.areasSubtitle
            : l10n.licenceDoctorSubtitle,
        error: _error,
        role: role,
        footer: TabibuButton.primary(
          label: l10n.commonContinue,
          onTap: _readingLicence ? null : _continue,
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            TabibuTextField(
              label: l10n.kmpdcLabel,
              hint: l10n.kmpdcHint,
              controller: _kmpdcController,
              leading: FieldIcon(Assets.icons.identityIcon),
              helperText: isPathologist ? null : l10n.kmpdcHelper,
              required: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: AppSpacing.md),
            if (isPathologist)
              _AreasField(
                selected: _specialties,
                onTap: _pickSpecialties,
                onRemoved: (specialty) => setState(() {
                  _specialties = _specialties
                      .where((s) => s != specialty)
                      .toList();
                  _error = null;
                }),
              )
            else
              PickerField(
                label: l10n.specialtyLabel,
                required: true,
                hint: l10n.specialtyPlaceholder,
                value: _specialties.isEmpty
                    ? null
                    : _specialties.map((s) => s.description(l10n)).join(' · '),
                leading: Assets.icons.stethoscopeIcon,
                onTap: _pickSpecialties,
              ),
            if (isPathologist) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.areasHelper,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _DocumentsSection(
              body: isPathologist
                  ? l10n.licenceDocsPathologistBody
                  : l10n.licenceDocsDoctorBody,
              licenses: _licenses,
              onAdd: _readingLicence || _licenses.length >= 2
                  ? null
                  : _addDocument,
              onDelete: (file) => setState(() {
                _licenses = _licenses.where((f) => f != file).toList();
                _error = null;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// F2's areas box: the chosen areas as removable chips.
class _AreasField extends StatelessWidget {
  const _AreasField({
    required this.selected,
    required this.onTap,
    required this.onRemoved,
  });

  final List<Specialty> selected;
  final VoidCallback onTap;
  final ValueChanged<Specialty> onRemoved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PickerField(
      label: l10n.areasLabel,
      required: true,
      hint: selected.isEmpty ? l10n.areasPlaceholder : null,
      leading: Assets.icons.testTubeIcon,
      excludeSemantics: false,
      onTap: onTap,
      child: selected.isEmpty
          ? null
          : Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final specialty in selected)
                  _AreaChip(
                    label: specialty.description(l10n),
                    removeLabel: l10n.removeArea(specialty.description(l10n)),
                    onRemoved: () => onRemoved(specialty),
                  ),
              ],
            ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({
    required this.label,
    required this.removeLabel,
    required this.onRemoved,
  });

  final String label;
  final String removeLabel;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.sm,
        top: AppSpacing.xxs,
        bottom: AppSpacing.xxs,
        right: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.brightness == .dark
            ? AppColors.lavenderDark
            : AppColors.lavenderLight,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Flexible(child: Text(label, style: textTheme.titleSmall)),
          const SizedBox(width: AppSpacing.xxs),
          Semantics(
            button: true,
            label: '$label, $removeLabel',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: onRemoved,
              behavior: HitTestBehavior.opaque,
              // The 48 dp floor wraps the hit area; the drawn cross keeps
              // its size, centered in the chip's height.
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Column(
                  mainAxisAlignment: .center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      child: AssetIcon(
                        Assets.icons.cancelIcon,
                        size: 18,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The required licence files: tiles with delete, and the add button until
/// two are attached.
class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    required this.body,
    required this.licenses,
    required this.onAdd,
    required this.onDelete,
  });

  final String body;
  final List<UploadFile> licenses;
  final VoidCallback? onAdd;
  final ValueChanged<UploadFile> onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text.rich(
          TextSpan(
            text: l10n.licenceDocsLabel,
            style: textTheme.titleMedium,
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: scheme.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(body, style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final file in licenses) ...[
          DocumentTile(
            fileName: file.name,
            meta: file.isPdf
                ? l10n.licenceMetaPdf(formatFileSize(file.bytes.length))
                : l10n.licenceMetaPhoto(formatFileSize(file.bytes.length)),
            deleteLabel: l10n.licenceDeleteLabel(file.name),
            onDelete: () => onDelete(file),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (onAdd != null)
          Semantics(
            button: true,
            onTap: onAdd,
            child: Material(
              color: scheme.brightness == .dark
                  ? AppColors.mintDark
                  : AppColors.mintLight,
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: GestureDetector(
                onTap: onAdd,
                behavior: .opaque,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      AssetIcon(Assets.icons.addIcon, size: 20),
                      const SizedBox(width: AppSpacing.xs),
                      Text(l10n.addDocument, style: textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
