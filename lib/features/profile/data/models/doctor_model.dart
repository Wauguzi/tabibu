import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'doctor_model.freezed.dart';
part 'doctor_model.g.dart';

/// A `doctors/{uid}` document, in §6.1 field order. Doctors and pathologists
/// share the collection, told apart by [isPathologist].
@freezed
abstract class DoctorModel with _$DoctorModel {
  const factory DoctorModel({
    @JsonKey(name: 'uid') required String uid,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'firstName') required String firstName,
    @JsonKey(name: 'lastName') required String lastName,
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'phoneNumber') required String phoneNumber,
    @JsonKey(name: 'profilePictureUrl') required String profilePictureUrl,
    @JsonKey(name: 'isPathologist') required bool isPathologist,
    @JsonKey(name: 'specialization') required String specialization,
    @JsonKey(name: 'bio') required String bio,
    @JsonKey(name: 'kmpdcNumber') required String kmpdcNumber,
    @JsonKey(name: 'licenseUrl') required String licenseUrl,
    @JsonKey(name: 'verificationStatus') required String verificationStatus,
    @JsonKey(name: 'facilityId') required String facilityId,
    @JsonKey(name: 'facilityMflCode') required String facilityMflCode,
    @JsonKey(name: 'facilityName') required String facilityName,
    @JsonKey(name: 'county') required String county,
    @JsonKey(name: 'subCounty') required String subCounty,
    @JsonKey(name: 'geohash') required String geohash,
    @JsonKey(name: 'isAvailable') required bool isAvailable,
    @JsonKey(name: 'fcmTokens') required List<String> fcmTokens,
    @JsonKey(name: 'language') required String language,
    @JsonKey(name: 'receiveNotifications') required bool receiveNotifications,
    @JsonKey(name: 'appointmentsHandled') required int appointmentsHandled,
    @JsonKey(name: 'ordersCreated') required int ordersCreated,
    @JsonKey(name: 'reportsSigned') required int reportsSigned,
    @JsonKey(name: 'termsAcceptedAt') required String termsAcceptedAt,
    @JsonKey(name: 'createdAt') required String createdAt,
    @JsonKey(name: 'lastUpdatedAt') required String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _DoctorModel;

  const DoctorModel._();

  factory DoctorModel.fromJson(Map<String, dynamic> json) =>
      _$DoctorModelFromJson(json);

  factory DoctorModel.empty() => const DoctorModel(
    uid: '',
    title: '',
    firstName: '',
    lastName: '',
    email: '',
    phoneNumber: '',
    profilePictureUrl: '',
    isPathologist: false,
    specialization: '',
    bio: '',
    kmpdcNumber: '',
    licenseUrl: '',
    verificationStatus: '',
    facilityId: '',
    facilityMflCode: '',
    facilityName: '',
    county: '',
    subCounty: '',
    geohash: '',
    isAvailable: false,
    fcmTokens: [],
    language: '',
    receiveNotifications: false,
    appointmentsHandled: 0,
    ordersCreated: 0,
    reportsSigned: 0,
    termsAcceptedAt: '',
    createdAt: '',
    lastUpdatedAt: '',
  );

  String get fullName =>
      [title, firstName, lastName].where((part) => part.isNotEmpty).join(' ');

  VerificationStatus get verificationStatusValue =>
      VerificationStatus.fromValue(verificationStatus);

  AppLanguage get languageValue => AppLanguage.fromValue(language);
}
