import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tabibu/core/constants/enums.dart';

part 'notification_metadata_model.freezed.dart';
part 'notification_metadata_model.g.dart';

/// Nested action metadata on a notification. [shareCode] is a secret: never
/// log it.
@Freezed(toStringOverride: false)
abstract class NotificationMetadataModel with _$NotificationMetadataModel {
  const factory NotificationMetadataModel({
    @JsonKey(name: 'actionType') @Default('') String actionType,
    @JsonKey(name: 'actionStatus') @Default('') String actionStatus,
    @JsonKey(name: 'actionedByUid') @Default('') String actionedByUid,
    @JsonKey(name: 'actionedAt') @Default('') String actionedAt,
    @JsonKey(name: 'expiresAt') @Default('') String expiresAt,
    @JsonKey(name: 'deepLink') @Default('') String deepLink,
    @JsonKey(name: 'shareCode') @Default('') String shareCode,
    @JsonKey(name: 'extras')
    @Default(<String, String>{})
    Map<String, String> extras,
  }) = _NotificationMetadataModel;

  const NotificationMetadataModel._();

  factory NotificationMetadataModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationMetadataModelFromJson(json);

  factory NotificationMetadataModel.empty() =>
      const NotificationMetadataModel();

  NotificationActionType get actionTypeValue =>
      NotificationActionType.fromValue(actionType);

  NotificationActionStatus get actionStatusValue =>
      NotificationActionStatus.fromValue(actionStatus);

  @override
  String toString() {
    final code = shareCode.isEmpty ? '' : '***';
    return 'NotificationMetadataModel(actionType: $actionType, '
        'actionStatus: $actionStatus, actionedByUid: $actionedByUid, '
        'actionedAt: $actionedAt, expiresAt: $expiresAt, deepLink: $deepLink, '
        'shareCode: $code, extras: $extras)';
  }
}
