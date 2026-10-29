import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart'
    show
        CupertinoDatePicker,
        CupertinoTheme,
        CupertinoThemeData,
        showCupertinoModalPopup;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_colors.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/routing/app_routes.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:tabibu/features/auth/blocs/sign_up_bloc/sign_up_event.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/sign_up_draft.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/widgets/draft_pop_scope.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_errors.dart';
import 'package:tabibu/features/auth/presentation/widgets/field_icon.dart';
import 'package:tabibu/features/auth/presentation/widgets/photo_row.dart';
import 'package:tabibu/features/auth/presentation/widgets/picker_field.dart';
import 'package:tabibu/features/auth/presentation/widgets/step_scaffold.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D1. Names, sex, birth date and the optional photo. When the account
/// already exists ([SignUpIncompleteSession]), Continue skips D2 and goes
/// straight to D3.
class PatientNameScreen extends StatefulWidget {
  const PatientNameScreen({super.key});

  @override
  State<PatientNameScreen> createState() => _PatientNameScreenState();
}

class _PatientNameScreenState extends State<PatientNameScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  Sex? _sex;
  DateTime? _birthDate;
  UploadFile? _picture;
  AppError? _error;
  bool _photoReading = false;

  @override
  void initState() {
    super.initState();
    final draft = context.read<SignUpBloc>().state.draft;
    _firstNameController = TextEditingController(text: draft.firstName);
    _middleNameController = TextEditingController(text: draft.middleName);
    _lastNameController = TextEditingController(text: draft.lastName);
    _sex = draft.sex;
    _birthDate = DateTime.tryParse(draft.dateOfBirth);
    _picture = draft.picture;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String get _avatarName {
    final name =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    return name;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final brightness = Theme.of(context).brightness;
    final surface = Theme.of(context).colorScheme.surfaceContainerLowest;
    // The date the sheet opens on is the field's: closing without
    // scrolling keeps it.
    final opening = _birthDate ?? DateTime(now.year - 25, now.month, now.day);
    setState(() {
      _birthDate = opening;
      _error = errorAfterChange(_error, .dateOfBirth);
    });
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: CupertinoTheme(
            data: CupertinoThemeData(brightness: brightness),
            child: CupertinoDatePicker(
              backgroundColor: Colors.transparent,
              initialDateTime: opening,
              minimumDate: DateTime(1900),
              maximumDate: now,
              mode: .date,
              onDateTimeChanged: (picked) => setState(() {
                _birthDate = picked;
                _error = errorAfterChange(_error, .dateOfBirth);
              }),
            ),
          ),
        ),
      ),
    );
  }

  SignUpDraft _fill(SignUpDraft draft) {
    final birthDate = _birthDate;
    return draft.copyWith(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      sex: _sex,
      dateOfBirth: birthDate == null
          ? ''
          : '${birthDate.year.toString().padLeft(4, '0')}-'
                '${birthDate.month.toString().padLeft(2, '0')}-'
                '${birthDate.day.toString().padLeft(2, '0')}',
      picture: _picture,
    );
  }

  void _continue() {
    final birthDate = _birthDate;
    final AppError? error;
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      error = AppError.invalidName;
    } else if (_sex == null) {
      error = AppError.invalidSex;
    } else if (birthDate == null) {
      error = AppError.invalidDateOfBirth;
    } else {
      error = null;
    }
    setState(() => _error = error);
    if (error != null) return;

    final draft = _fill(context.read<SignUpBloc>().state.draft);
    context.read<SignUpBloc>().add(SignUpDraftUpdated(draft: draft));

    final session = context.read<AuthBloc>().state.session;
    if (session is SignUpIncompleteSession) {
      unawaited(const PatientPhoneRoute().push<void>(context));
    } else {
      unawaited(const PatientAccountRoute().push<void>(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final birthDate = _birthDate;
    final error = _error;
    final firstEmpty = _firstNameController.text.trim().isEmpty;
    final lastEmpty = _lastNameController.text.trim().isEmpty;

    return DraftPopScope(
      fill: _fill,
      child: StepScaffold(
        step: 1,
        total: 4,
        backLabel: l10n.commonBack,
        onBack: () => Navigator.of(context).pop(),
        title: l10n.patientNameTitle,
        subtitle: l10n.patientNameSubtitle,
        error: error != null && fieldFor(error) == null ? error : null,
        role: Role.patient,
        footer: TabibuButton.primary(
          label: l10n.commonContinue,
          onTap: _photoReading ? null : _continue,
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            PhotoRow(
              name: _avatarName,
              title: l10n.photoTitle,
              body: l10n.photoPatientBody,
              picture: _picture,
              onPicked: (file) => setState(() => _picture = file),
              onReading: (reading) => setState(() => _photoReading = reading),
            ),
            const SizedBox(height: AppSpacing.md),
            TabibuTextField(
              label: l10n.firstNameLabel,
              controller: _firstNameController,
              leading: FieldIcon(Assets.icons.personIcon),
              errorText: _error == .invalidName && firstEmpty
                  ? fieldErrorText(_error!, l10n)
                  : null,
              required: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
              onChanged: (_) =>
                  setState(() => _error = errorAfterChange(_error, .name)),
            ),
            const SizedBox(height: AppSpacing.md),
            TabibuTextField(
              label: l10n.middleNameLabel,
              controller: _middleNameController,
              leading: FieldIcon(Assets.icons.personIcon),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.middleName],
            ),
            const SizedBox(height: AppSpacing.md),
            TabibuTextField(
              label: l10n.lastNameLabel,
              controller: _lastNameController,
              leading: FieldIcon(Assets.icons.personIcon),
              errorText: _error == .invalidName && !firstEmpty && lastEmpty
                  ? fieldErrorText(_error!, l10n)
                  : null,
              required: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.familyName],
              onChanged: (_) =>
                  setState(() => _error = errorAfterChange(_error, .name)),
            ),
            const SizedBox(height: AppSpacing.md),
            _SexPicker(
              label: l10n.sexLabel,
              value: _sex,
              errorText: _error == .invalidSex
                  ? fieldErrorText(_error!, l10n)
                  : null,
              onChanged: (sex) => setState(() {
                _sex = sex;
                _error = errorAfterChange(_error, .sex);
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            PickerField(
              label: l10n.dobLabel,
              required: true,
              hint: l10n.dobHint,
              value: birthDate == null
                  ? null
                  : DateFormat(
                      'd MMM y',
                      Localizations.localeOf(context).languageCode,
                    ).format(birthDate),
              leading: Assets.icons.calendarIcon,
              errorText: _error == .invalidDateOfBirth
                  ? fieldErrorText(_error!, l10n)
                  : null,
              onTap: _pickBirthDate,
            ),
          ],
        ),
      ),
    );
  }
}

/// D1's two sex cards, in the design's large format.
class _SexPicker extends StatelessWidget {
  const _SexPicker({
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final Sex? value;
  final ValueChanged<Sex> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final errorText = this.errorText;
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text.rich(
          TextSpan(
            text: label,
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
        Row(
          children: [
            // Female first, as designed; the enum keeps its order.
            for (final sex in <Sex>[.female, .male]) ...[
              Expanded(
                child: _SexCard(
                  sex: sex,
                  selected: value == sex,
                  onTap: () => onChanged(sex),
                ),
              ),
              if (sex != .male) const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText,
            style: textTheme.bodySmall?.copyWith(color: scheme.error),
            maxLines: 3,
          ),
        ],
      ],
    );
  }
}

class _SexCard extends StatelessWidget {
  const _SexCard({
    required this.sex,
    required this.selected,
    required this.onTap,
  });

  final Sex sex;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        onTap: onTap,
        // The InkWell's focus, kept: it merges into the card's node.
        child: Focus(
          canRequestFocus: true,
          child: Material(
            color: selected
                ? (scheme.brightness == Brightness.dark
                      ? AppColors.mintDark
                      : AppColors.mintLight)
                : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: GestureDetector(
              onTap: onTap,
              behavior: .opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4,
                ),
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    ExcludeSemantics(
                      child: AssetIcon(
                        selected
                            ? Assets.icons.checkSelectedIcon
                            : Assets.icons.checkUnselectedIcon,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        sex.description(context.l10n),
                        style: textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
