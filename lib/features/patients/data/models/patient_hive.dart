import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/patients/data/models/patient_model.dart';

part 'patient_hive.g.dart';

/// Cached [PatientModel], in the same field order.
@HiveType(typeId: 0)
class PatientHive {
  PatientHive({
    required this.patientId,
    required this.uid,
    required this.isRegistered,
    required this.createdByUid,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.sex,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    required this.profilePictureUrl,
    required this.county,
    required this.subCounty,
    required this.geohash,
    required this.doctorUids,
    required this.fcmTokens,
    required this.language,
    required this.receiveNotifications,
    required this.casesReported,
    required this.appointmentsBooked,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory PatientHive.fromModel(PatientModel model) {
    return PatientHive(
      patientId: model.patientId,
      uid: model.uid,
      isRegistered: model.isRegistered,
      createdByUid: model.createdByUid,
      firstName: model.firstName,
      middleName: model.middleName,
      lastName: model.lastName,
      sex: model.sex,
      dateOfBirth: model.dateOfBirth,
      phoneNumber: model.phoneNumber,
      email: model.email,
      profilePictureUrl: model.profilePictureUrl,
      county: model.county,
      subCounty: model.subCounty,
      geohash: model.geohash,
      doctorUids: model.doctorUids,
      fcmTokens: model.fcmTokens,
      language: model.language,
      receiveNotifications: model.receiveNotifications,
      casesReported: model.casesReported,
      appointmentsBooked: model.appointmentsBooked,
      createdAt: model.createdAt,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  PatientModel toModel() {
    return PatientModel(
      patientId: patientId,
      uid: uid,
      isRegistered: isRegistered,
      createdByUid: createdByUid,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      sex: sex,
      dateOfBirth: dateOfBirth,
      phoneNumber: phoneNumber,
      email: email,
      profilePictureUrl: profilePictureUrl,
      county: county,
      subCounty: subCounty,
      geohash: geohash,
      doctorUids: doctorUids,
      fcmTokens: fcmTokens,
      language: language,
      receiveNotifications: receiveNotifications,
      casesReported: casesReported,
      appointmentsBooked: appointmentsBooked,
      createdAt: createdAt,
      lastUpdatedAt: lastUpdatedAt,
      synced: synced,
    );
  }

  @HiveField(0)
  final String patientId;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final bool isRegistered;

  @HiveField(3)
  final String createdByUid;

  @HiveField(4)
  final String firstName;

  @HiveField(5)
  final String middleName;

  @HiveField(6)
  final String lastName;

  @HiveField(7)
  final String sex;

  @HiveField(8)
  final String dateOfBirth;

  @HiveField(9)
  final String phoneNumber;

  @HiveField(10)
  final String email;

  @HiveField(11)
  final String profilePictureUrl;

  @HiveField(12)
  final String county;

  @HiveField(13)
  final String subCounty;

  @HiveField(14)
  final String geohash;

  @HiveField(15)
  final List<String> doctorUids;

  @HiveField(16)
  final List<String> fcmTokens;

  @HiveField(17)
  final String language;

  @HiveField(18)
  final bool receiveNotifications;

  @HiveField(19)
  final int casesReported;

  @HiveField(20)
  final int appointmentsBooked;

  @HiveField(21)
  final String createdAt;

  @HiveField(22)
  final String lastUpdatedAt;

  @HiveField(23)
  final bool synced;
}
