import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

/// A `patients/{patientId}` document, in §6.1 field order.
@freezed
abstract class PatientModel with _$PatientModel {
  const factory PatientModel({
    @JsonKey(name: 'patientId') required String patientId,
    @JsonKey(name: 'uid') required String uid,
    @JsonKey(name: 'isRegistered') required bool isRegistered,
    @JsonKey(name: 'createdByUid') required String createdByUid,
    @JsonKey(name: 'firstName') required String firstName,
    @JsonKey(name: 'middleName') required String middleName,
    @JsonKey(name: 'lastName') required String lastName,
    @JsonKey(name: 'sex') required String sex,
    @JsonKey(name: 'dateOfBirth') required String dateOfBirth,
    @JsonKey(name: 'phoneNumber') required String phoneNumber,
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'profilePictureUrl') required String profilePictureUrl,
    @JsonKey(name: 'county') required String county,
    @JsonKey(name: 'subCounty') required String subCounty,
    @JsonKey(name: 'geohash') required String geohash,
    @JsonKey(name: 'doctorUids') required List<String> doctorUids,
    @JsonKey(name: 'fcmTokens') required List<String> fcmTokens,
    @JsonKey(name: 'language') required String language,
    @JsonKey(name: 'receiveNotifications') required bool receiveNotifications,
    @JsonKey(name: 'casesReported') required int casesReported,
    @JsonKey(name: 'appointmentsBooked') required int appointmentsBooked,
    @JsonKey(name: 'createdAt') required String createdAt,
    @JsonKey(name: 'lastUpdatedAt') required String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _PatientModel;

  const PatientModel._();

  factory PatientModel.fromJson(Map<String, dynamic> json) =>
      _$PatientModelFromJson(json);

  factory PatientModel.empty() => const PatientModel(
    patientId: '',
    uid: '',
    isRegistered: false,
    createdByUid: '',
    firstName: '',
    middleName: '',
    lastName: '',
    sex: '',
    dateOfBirth: '',
    phoneNumber: '',
    email: '',
    profilePictureUrl: '',
    county: '',
    subCounty: '',
    geohash: '',
    doctorUids: [],
    fcmTokens: [],
    language: '',
    receiveNotifications: false,
    casesReported: 0,
    appointmentsBooked: 0,
    createdAt: '',
    lastUpdatedAt: '',
  );

  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((part) => part.isNotEmpty).join(' ');

  Sex? get sexValue => Sex.fromValue(sex);

  AppLanguage get languageValue => AppLanguage.fromValue(language);

  /// Whole years from [dateOfBirth] at [now], by calendar date.
  int ageOn(DateTime now) {
    final birth = DateTime.tryParse(dateOfBirth);
    if (birth == null) {
      // The message carries no patient data: exception text reaches
      // Crashlytics, which must never see it.
      throw StateError('PatientModel has an invalid date of birth.');
    }
    var age = now.year - birth.year;
    final beforeBirthday =
        now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day);
    if (beforeBirthday) age--;
    return age;
  }
}
