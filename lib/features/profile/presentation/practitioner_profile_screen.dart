import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabibu/core/constants/app_radii.dart';
import 'package:tabibu/core/constants/app_spacing.dart';
import 'package:tabibu/core/constants/enums.dart';
import 'package:tabibu/core/helpers/get_it_helper.dart';
import 'package:tabibu/core/services/file_picker_service.dart';
import 'package:tabibu/core/widgets/widgets.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_bloc.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_event.dart';
import 'package:tabibu/features/auth/blocs/auth_bloc/auth_state.dart';
import 'package:tabibu/features/auth/data/models/auth_session.dart';
import 'package:tabibu/features/auth/data/models/upload_file.dart';
import 'package:tabibu/features/auth/presentation/widgets/picker_field.dart';
import 'package:tabibu/features/auth/presentation/widgets/specialty_sheet.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_form.dart';
import 'package:tabibu/features/profile/presentation/widgets/profile_identity_card.dart';
import 'package:tabibu/gen/assets.gen.dart';
import 'package:tabibu/l10n/l10n.dart';

/// D- and PA-PROFILE details in one screen: the identity hero, a photo
/// button, the patient-facing fields, then the Tabibu-only ones. Specialty,
/// bio, phone and photo save; names stay locked once verified, the email is
/// shown read-only, and the licence card is locked. The frame's spoken
/// languages row stays out: the data model has no such field. [role]
/// switches the shown-to title and the specialty list.
class PractitionerProfileScreen extends StatefulWidget {
  const PractitionerProfileScreen({required this.role, super.key});

  final Role role;

  @override
  State<PractitionerProfileScreen> createState() =>
      _PractitionerDetailsScreenState();
}

class _PractitionerDetailsScreenState extends State<PractitionerProfileScreen> {
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _bio = TextEditingController();
  late final TextEditingController _phone = TextEditingController();
  late final TextEditingController _email = TextEditingController();
  List<String> _specialties = const [];
  UploadFile? _picture;
  String? _bioError;
  String? _phoneError;
  bool _saving = false;
  bool _filled = false;

  bool get _isPathologist => widget.role == .pathologist;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  /// The session's values fill the fields once; a rebuild mid-edit must not
  /// clobber typed text.
  void _fillOnce(DoctorModel doctor) {
    if (_filled) return;
    _filled = true;
    _name.text = '${doctor.title} ${doctor.firstName} ${doctor.lastName}'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    _specialties = List.of(doctor.specialties);
    _bio.text = doctor.bio;
    _phone.text = doctor.phoneNumber;
    _email.text = doctor.email;
  }

  Future<void> _pickSpecialties() async {
    final l10n = context.l10n;
    final isPathologist = _isPathologist;
    final options = Specialty.forRole(isPathologist: isPathologist);
    final current = _specialties
        .map(Specialty.fromValue)
        .nonNulls
        .where(options.contains)
        .toList();
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
      initial: current,
      allowed: options,
    );
    // An empty pick keeps the old list: the rules take one to five.
    if (picked == null || picked.isEmpty || !mounted) return;
    setState(() => _specialties = picked.map((s) => s.value).toList());
  }

  void _save() {
    final l10n = context.l10n;
    final phone = normalizeKenyanPhone(_phone.text);
    final bio = _bio.text.trim();
    setState(() {
      _phoneError = phone == null ? l10n.profileDetailsBadPhone : null;
      _bioError = bio.length > 1000 ? l10n.profileDetailsBioTooLong : null;
    });
    if (phone == null || bio.length > 1000) return;
    setState(() => _saving = true);
    context.read<AuthBloc>().add(
      PractitionerProfileChanged(
        specialties: _specialties,
        bio: bio,
        phoneNumber: phone,
        picture: _picture,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final background = _isPathologist
        ? RoleBackground.pathologist
        : RoleBackground.doctor;
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
                  title: l10n.profileDetailsTitle,
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
                    final doctor = switch (state.session) {
                      PractitionerSession(:final doctor) => doctor,
                      _ => null,
                    };
                    // The router bounces the signed-out off role paths; this is
                    // the frame between a sign-out and its redirect.
                    if (doctor == null) return const SizedBox.shrink();
                    _fillOnce(doctor);
                    final specialtyNames = _specialties
                        .map(
                          (value) =>
                              Specialty.fromValue(value)?.description(l10n) ??
                              value,
                        )
                        .join(' · ');
                    final heroRole = doctor.isPathologist
                        ? l10n.profilePathologist
                        : doctor.specialties
                              .map(
                                (value) =>
                                    Specialty.fromValue(
                                      value,
                                    )?.description(l10n) ??
                                    value,
                              )
                              .join(' · ');
                    return Column(
                      crossAxisAlignment: .stretch,
                      children: [
                        PractitionerIdentityCard(
                          name: doctor.fullName,
                          subtitle: heroRole.isEmpty
                              ? doctor.facilityName
                              : l10n.profileRoleAtFacility(
                                  heroRole,
                                  doctor.facilityName,
                                ),
                          verifiedLabel: l10n.doctorProfileVerified,
                          photoUrl: doctor.profilePictureUrl,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PhotoButton(
                          url: doctor.profilePictureUrl,
                          picked: _picture,
                          onPicked: (file) => setState(() => _picture = file),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          _isPathologist
                              ? l10n.profileDetailsShownDoctors
                              : l10n.profileDetailsShownPatients,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TabibuTextField(
                          label: l10n.profileDetailsFullName,
                          controller: _name,
                          leading: AssetIcon(Assets.icons.personIcon, size: 20),
                          readOnly: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PickerField(
                          label: l10n.profileDetailsSpecialty,
                          value: specialtyNames,
                          leading: Assets.icons.stethoscopeIcon,
                          onTap: _pickSpecialties,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.profileDetailsAbout,
                          controller: _bio,
                          maxLines: 4,
                          errorText: _bioError,
                          onChanged: (_) => setState(() => _bioError = null),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.profileDetailsOnlyTabibu,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TabibuTextField(
                          label: l10n.profileDetailsPhone,
                          controller: _phone,
                          leading: AssetIcon(Assets.icons.phoneIcon, size: 20),
                          keyboardType: .phone,
                          errorText: _phoneError,
                          onChanged: (_) => setState(() => _phoneError = null),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TabibuTextField(
                          label: l10n.profileDetailsEmail,
                          controller: _email,
                          leading: AssetIcon(Assets.icons.emailIcon, size: 20),
                          readOnly: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _LicenceCard(
                          doctor: doctor,
                          isPathologist: _isPathologist,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        NoticeCard(
                          variant: .info,
                          icon: Assets.icons.infoIcon,
                          body: l10n.profileDetailsLicenceLocked,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TabibuButton.primary(
                          label: l10n.profileDetailsSave,
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
    return Scaffold(body: background(child: body));
  }
}

/// The full-width photo button: opens the camera/library sheet and previews
/// the pick.
class _PhotoButton extends StatefulWidget {
  const _PhotoButton({required this.url, required this.onPicked, this.picked});

  final String url;
  final ValueChanged<UploadFile> onPicked;
  final UploadFile? picked;

  @override
  State<_PhotoButton> createState() => _PhotoButtonState();
}

class _PhotoButtonState extends State<_PhotoButton> {
  bool _reading = false;

  Future<void> _sheet() async {
    if (_reading) return;
    final l10n = context.l10n;
    final fromCamera = await TabibuBottomSheet.show<bool>(
      context,
      title: l10n.photoTitle,
      cancelLabel: l10n.commonCancel,
      builder: (context) => Column(
        mainAxisSize: .min,
        children: [
          OptionCard(
            icon: Assets.icons.photoIcon,
            tone: .sky,
            title: l10n.photoTake,
            selected: false,
            chevron: true,
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.sm),
          OptionCard(
            icon: Assets.icons.uploadIcon,
            tone: .lavender,
            title: l10n.photoLibrary,
            selected: false,
            chevron: true,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    if (fromCamera == null || !context.mounted) return;
    setState(() => _reading = true);
    try {
      final file = await getIt<FilePickerService>().pickPhoto(
        fromCamera: fromCamera,
      );
      if (!mounted) return;
      if (file != null) widget.onPicked(file);
    } on AppError catch (error) {
      if (!mounted) return;
      final l10n = context.l10n;
      unawaited(
        showTabibuNotification(
          context,
          message: error.description(l10n),
          isError: true,
          dismissLabel: l10n.commonDismiss,
        ),
      );
    } on Object catch (_) {
      if (!mounted) return;
      final l10n = context.l10n;
      unawaited(
        showTabibuNotification(
          context,
          message: AppError.unknown.description(l10n),
          isError: true,
          dismissLabel: l10n.commonDismiss,
        ),
      );
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final picked = widget.picked;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        if (picked != null) ...[
          Center(
            child: Avatar(
              name: '',
              image: MemoryImage(picked.bytes),
              radius: 44,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TabibuButton.outline(
          label: context.l10n.profileDetailsChangePhoto,
          icon: AssetIcon(Assets.icons.photoIcon, size: 20),
          isLoading: _reading,
          onTap: _reading ? null : _sheet,
        ),
      ],
    );
  }
}

/// The licence number with its lock. Verified and renewal dates have no
/// fields on the profile, so the card carries the number alone.
class _LicenceCard extends StatelessWidget {
  const _LicenceCard({required this.doctor, required this.isPathologist});

  final DoctorModel doctor;
  final bool isPathologist;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          IconTile(
            icon: Assets.icons.signedIcon,
            tone: isPathologist ? .lavender : .mint,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l10n.profileDetailsLicence(doctor.kmpdcNumber),
              style: textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
