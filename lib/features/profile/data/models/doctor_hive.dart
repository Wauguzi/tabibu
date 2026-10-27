import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/profile/data/models/doctor_model.dart';

part 'doctor_hive.g.dart';

/// Cached [DoctorModel], in the same field order.
@HiveType(typeId: 1)
class DoctorHive {
  DoctorHive({
    required this.uid,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.profilePictureUrl,
    required this.isPathologist,
    required this.specialization,
    required this.bio,
    required this.kmpdcNumber,
    required this.licenseUrl,
    required this.verificationStatus,
    required this.facilityId,
    required this.facilityMflCode,
    required this.facilityName,
    required this.county,
    required this.subCounty,
    required this.geohash,
    required this.isAvailable,
    required this.fcmTokens,
    required this.language,
    required this.receiveNotifications,
    required this.appointmentsHandled,
    required this.ordersCreated,
    required this.reportsSigned,
    required this.termsAcceptedAt,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory DoctorHive.fromModel(DoctorModel model) {
    return DoctorHive(
      uid: model.uid,
      title: model.title,
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      phoneNumber: model.phoneNumber,
      profilePictureUrl: model.profilePictureUrl,
      isPathologist: model.isPathologist,
      specialization: model.specialization,
      bio: model.bio,
      kmpdcNumber: model.kmpdcNumber,
      licenseUrl: model.licenseUrl,
      verificationStatus: model.verificationStatus,
      facilityId: model.facilityId,
      facilityMflCode: model.facilityMflCode,
      facilityName: model.facilityName,
      county: model.county,
      subCounty: model.subCounty,
      geohash: model.geohash,
      isAvailable: model.isAvailable,
      fcmTokens: model.fcmTokens,
      language: model.language,
      receiveNotifications: model.receiveNotifications,
      appointmentsHandled: model.appointmentsHandled,
      ordersCreated: model.ordersCreated,
      reportsSigned: model.reportsSigned,
      termsAcceptedAt: model.termsAcceptedAt,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  DoctorModel toModel() {
    return DoctorModel(
      uid: uid,
      title: title,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      isPathologist: isPathologist,
      specialization: specialization,
      bio: bio,
      kmpdcNumber: kmpdcNumber,
      licenseUrl: licenseUrl,
      verificationStatus: verificationStatus,
      facilityId: facilityId,
      facilityMflCode: facilityMflCode,
      facilityName: facilityName,
      county: county,
      subCounty: subCounty,
      geohash: geohash,
      isAvailable: isAvailable,
      fcmTokens: fcmTokens,
      language: language,
      receiveNotifications: receiveNotifications,
      appointmentsHandled: appointmentsHandled,
      ordersCreated: ordersCreated,
      reportsSigned: reportsSigned,
      termsAcceptedAt: termsAcceptedAt,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String firstName;

  @HiveField(3)
  final String lastName;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String phoneNumber;

  @HiveField(6)
  final String profilePictureUrl;

  @HiveField(7)
  final bool isPathologist;

  @HiveField(8)
  final String specialization;

  @HiveField(9)
  final String bio;

  @HiveField(10)
  final String kmpdcNumber;

  @HiveField(11)
  final String licenseUrl;

  @HiveField(12)
  final String verificationStatus;

  @HiveField(13)
  final String facilityId;

  @HiveField(14)
  final String facilityMflCode;

  @HiveField(15)
  final String facilityName;

  @HiveField(16)
  final String county;

  @HiveField(17)
  final String subCounty;

  @HiveField(18)
  final String geohash;

  @HiveField(19)
  final bool isAvailable;

  @HiveField(20)
  final List<String> fcmTokens;

  @HiveField(21)
  final String language;

  @HiveField(22)
  final bool receiveNotifications;

  @HiveField(23)
  final int appointmentsHandled;

  @HiveField(24)
  final int ordersCreated;

  @HiveField(25)
  final int reportsSigned;

  @HiveField(26)
  final String termsAcceptedAt;

  @HiveField(27)
  final String createdAt;

  @HiveField(28)
  final String lastUpdatedAt;

  @HiveField(29)
  final bool synced;
}
