import 'package:hive_ce/hive.dart';
import 'package:tabibu/features/practitioners/data/models/practitioner_model.dart';

part 'practitioner_hive.g.dart';

/// Cached [PractitionerModel], in the same field order.
@HiveType(typeId: 2)
class PractitionerHive {
  PractitionerHive({
    required this.uid,
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.isPathologist,
    required this.specialization,
    required this.bio,
    required this.facilityId,
    required this.facilityMflCode,
    required this.facilityName,
    required this.county,
    required this.subCounty,
    required this.geohash,
    required this.isAvailable,
    required this.appointmentsHandled,
    required this.ordersCreated,
    required this.reportsSigned,
    required this.lastUpdatedAt,
    required this.synced,
  });

  factory PractitionerHive.fromModel(PractitionerModel model) {
    return PractitionerHive(
      uid: model.uid,
      title: model.title,
      firstName: model.firstName,
      lastName: model.lastName,
      profilePictureUrl: model.profilePictureUrl,
      isPathologist: model.isPathologist,
      specialization: model.specialization,
      bio: model.bio,
      facilityId: model.facilityId,
      facilityMflCode: model.facilityMflCode,
      facilityName: model.facilityName,
      county: model.county,
      subCounty: model.subCounty,
      geohash: model.geohash,
      isAvailable: model.isAvailable,
      appointmentsHandled: model.appointmentsHandled,
      ordersCreated: model.ordersCreated,
      reportsSigned: model.reportsSigned,
      lastUpdatedAt: model.lastUpdatedAt,
      synced: model.synced,
    );
  }

  PractitionerModel toModel() {
    return PractitionerModel(
      uid: uid,
      title: title,
      firstName: firstName,
      lastName: lastName,
      profilePictureUrl: profilePictureUrl,
      isPathologist: isPathologist,
      specialization: specialization,
      bio: bio,
      facilityId: facilityId,
      facilityMflCode: facilityMflCode,
      facilityName: facilityName,
      county: county,
      subCounty: subCounty,
      geohash: geohash,
      isAvailable: isAvailable,
      appointmentsHandled: appointmentsHandled,
      ordersCreated: ordersCreated,
      reportsSigned: reportsSigned,
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
  final String profilePictureUrl;

  @HiveField(5)
  final bool isPathologist;

  @HiveField(6)
  final String specialization;

  @HiveField(7)
  final String bio;

  @HiveField(8)
  final String facilityId;

  @HiveField(9)
  final String facilityMflCode;

  @HiveField(10)
  final String facilityName;

  @HiveField(11)
  final String county;

  @HiveField(12)
  final String subCounty;

  @HiveField(13)
  final String geohash;

  @HiveField(14)
  final bool isAvailable;

  @HiveField(15)
  final int appointmentsHandled;

  @HiveField(16)
  final int ordersCreated;

  @HiveField(17)
  final int reportsSigned;

  @HiveField(18)
  final String lastUpdatedAt;

  @HiveField(19)
  final bool synced;
}
