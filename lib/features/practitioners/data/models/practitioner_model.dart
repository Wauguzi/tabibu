import 'package:freezed_annotation/freezed_annotation.dart';

part 'practitioner_model.freezed.dart';
part 'practitioner_model.g.dart';

/// A `practitioners/{uid}` directory entry: the public subset of `doctors`,
/// in the same order. Never carries contact details, tokens or licenses.
@freezed
abstract class PractitionerModel with _$PractitionerModel {
  const factory PractitionerModel({
    @JsonKey(name: 'uid') required String uid,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'firstName') required String firstName,
    @JsonKey(name: 'lastName') required String lastName,
    @JsonKey(name: 'profilePictureUrl') required String profilePictureUrl,
    @JsonKey(name: 'isPathologist') required bool isPathologist,
    @JsonKey(name: 'specialization') required String specialization,
    @JsonKey(name: 'bio') required String bio,
    @JsonKey(name: 'facilityId') required String facilityId,
    @JsonKey(name: 'facilityMflCode') required String facilityMflCode,
    @JsonKey(name: 'facilityName') required String facilityName,
    @JsonKey(name: 'county') required String county,
    @JsonKey(name: 'subCounty') required String subCounty,
    @JsonKey(name: 'geohash') required String geohash,
    @JsonKey(name: 'isAvailable') required bool isAvailable,
    @JsonKey(name: 'appointmentsHandled') required int appointmentsHandled,
    @JsonKey(name: 'ordersCreated') required int ordersCreated,
    @JsonKey(name: 'reportsSigned') required int reportsSigned,
    @JsonKey(name: 'lastUpdatedAt') required String lastUpdatedAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(true)
    bool synced,
  }) = _PractitionerModel;

  const PractitionerModel._();

  factory PractitionerModel.fromJson(Map<String, dynamic> json) =>
      _$PractitionerModelFromJson(json);

  factory PractitionerModel.empty() => const PractitionerModel(
    uid: '',
    title: '',
    firstName: '',
    lastName: '',
    profilePictureUrl: '',
    isPathologist: false,
    specialization: '',
    bio: '',
    facilityId: '',
    facilityMflCode: '',
    facilityName: '',
    county: '',
    subCounty: '',
    geohash: '',
    isAvailable: false,
    appointmentsHandled: 0,
    ordersCreated: 0,
    reportsSigned: 0,
    lastUpdatedAt: '',
  );

  String get fullName =>
      [title, firstName, lastName].where((part) => part.isNotEmpty).join(' ');
}
