import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_form.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// P-PROFILE-EDIT edit. Names, phone and photo save; date of birth, sex and
/// email are shown read-only (no client writes them), and the frame's
/// care-team, emergency and cover fields stay out: the data model has no
/// fields for them (F-3). Invalid input never leaves the screen.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _first = TextEditingController();
  late final TextEditingController _middle = TextEditingController();
  late final TextEditingController _last = TextEditingController();
  late final TextEditingController _phone = TextEditingController();
  late final TextEditingController _birth = TextEditingController();
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _sex = TextEditingController();
  UploadFile? _picture;
  String? _firstError;
  String? _lastError;
  String? _phoneError;
  bool _saving = false;
  bool _filled = false;

  @override
  void dispose() {
    _first.dispose();
    _middle.dispose();
    _last.dispose();
    _phone.dispose();
    _birth.dispose();
    _email.dispose();
    _sex.dispose();
    super.dispose();
  }

  /// The session's values fill the fields once; a rebuild mid-edit must not
  /// clobber typed text.
  void _fillOnce(PatientModel patient, AppLocalizations l10n) {
    if (_filled) return;
    _filled = true;
    _first.text = patient.firstName;
    _middle.text = patient.middleName;
    _last.text = patient.lastName;
    _phone.text = patient.phoneNumber;
    _email.text = patient.email;
    final language = Localizations.localeOf(context).languageCode;
    final birth = DateTime.tryParse(patient.dateOfBirth);
    _birth.text = birth == null
        ? ''
        : DateFormat('d MMM y', language).format(birth);
    _sex.text = Sex.fromValue(patient.sex)?.description(l10n) ?? patient.sex;
  }

  void _save() {
    final l10n = context.l10n;
    final first = _first.text.trim();
    final middle = _middle.text.trim();
    final last = _last.text.trim();
    final phone = normalizeKenyanPhone(_phone.text);
    setState(() {
      _firstError = first.isEmpty ? l10n.editProfileFirstRequired : null;
      _lastError = last.isEmpty ? l10n.editProfileLastRequired : null;
      _phoneError = phone == null ? l10n.editProfileBadPhone : null;
    });
    if (first.isEmpty || last.isEmpty || phone == null) return;
    setState(() => _saving = true);
    context.read<AuthBloc>().add(
      PatientProfileChanged(
        firstName: first,
        middleName: middle,
        lastName: last,
        phoneNumber: phone,
        picture: _picture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final body = SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenMargin,
              AppSpacing.md,
              AppSpacing.screenMargin,
              AppSpacing.md,
            ),
            sliver: SliverList.list(
              children: [
                TopBar(
                  backLabel: l10n.commonBack,
                  onBack: context.pop,
                  title: l10n.editProfileEditTitle,
                ),
                const SizedBox(height: AppSpacing.md),
                BlocConsumer<AuthBloc, AuthState>(
                  listenWhen: (_, _) => _saving,
                  listener: (context, state) {
                    switch (state) {
                      case ProfileSaveSuccess():
                        context.pop();
                      case ProfileSaveFailure(:final error):
                        setState(() => _saving = false);
                        unawaited(
                          showTabibuNotification(
                            context,
                            message: error.description(l10n),
                            isError: true,
                            dismissLabel: l10n.commonDismiss,
                          ),
                        );
                      default:
                        break;
                    }
                  },
                  builder: (context, state) {
                    final patient = switch (state.session) {
                      PatientSession(:final patient) => patient,
                      _ => null,
                    };
                    // The router bounces the signed-out off role paths; this is
                    // the frame between a sign-out and its redirect.
                    if (patient == null) return const SizedBox.shrink();
                    _fillOnce(patient, l10n);
                    return Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        ProfilePhotoEditor(
                          name: '${patient.firstName} ${patient.lastName}',
                          changeLabel: l10n.profileDetailsChangePhoto,
                          url: patient.profilePictureUrl,
                          picked: _picture?.bytes,
                          onPicked: (file) => setState(() => _picture = file),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TabibuTextField(
                          label: l10n.editProfileFirstName,
                          controller: _first,
                          maxLength: 50,
                          required: true,
                          leading: AssetIcon(Assets.icons.personIcon, size: 20),
                          errorText: _firstError,
                          onChanged: (_) => setState(() => _firstError = null),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.editProfileMiddleName,
                          controller: _middle,
                          maxLength: 50,
                          leading: AssetIcon(Assets.icons.personIcon, size: 20),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.editProfileLastName,
                          controller: _last,
                          maxLength: 50,
                          required: true,
                          leading: AssetIcon(Assets.icons.personIcon, size: 20),
                          errorText: _lastError,
                          onChanged: (_) => setState(() => _lastError = null),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.editProfileDob,
                          controller: _birth,
                          leading: AssetIcon(
                            Assets.icons.calendarIcon,
                            size: 20,
                          ),
                          readOnly: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.editProfilePhoneNumber,
                          controller: _phone,
                          required: true,
                          leading: AssetIcon(Assets.icons.phoneIcon, size: 20),
                          keyboardType: .phone,
                          errorText: _phoneError,
                          onChanged: (_) => setState(() => _phoneError = null),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.editProfileEmail,
                          controller: _email,
                          leading: AssetIcon(Assets.icons.emailIcon, size: 20),
                          readOnly: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.editProfileSex,
                          controller: _sex,
                          leading: AssetIcon(Assets.icons.personIcon, size: 20),
                          readOnly: true,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.editProfileLockedNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TabibuButton.primary(
                          label: l10n.editProfileSave,
                          isLoading: _saving,
                          onTap: _saving ? null : _save,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(body: RoleBackground.patient(child: body));
  }
}
