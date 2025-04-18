// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationProfile _$NotificationProfileFromJson(Map<String, dynamic> json) =>
    NotificationProfile(
      email: json['email'] as String? ?? '',
      allowNotifications: json['allow_notifications'] as bool? ?? false,
      notificationInterval: $enumDecodeNullable(
              _$NotificationIntervalEnumMap, json['notification_interval']) ??
          NotificationInterval.oneHour,
    );

Map<String, dynamic> _$NotificationProfileToJson(
        NotificationProfile instance) =>
    <String, dynamic>{
      'allow_notifications': instance.allowNotifications,
      'notification_interval':
          _$NotificationIntervalEnumMap[instance.notificationInterval]!,
    };

const _$NotificationIntervalEnumMap = {
  NotificationInterval.fifteenMin: '15 mins',
  NotificationInterval.thirtyMin: '30 mins',
  NotificationInterval.oneHour: '1 hour',
  NotificationInterval.twoHour: '2 hours',
  NotificationInterval.fourHour: '4 hours',
  NotificationInterval.eightHour: '8 hours',
  NotificationInterval.oneDay: '1 day',
};
