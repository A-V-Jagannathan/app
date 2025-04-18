import 'package:json_annotation/json_annotation.dart';

part 'notification_profile_model.g.dart';

@JsonEnum(valueField: 'value')
enum NotificationInterval {
  fifteenMin('15 mins'),
  thirtyMin('30 mins'),
  oneHour('1 hour'),
  twoHour('2 hours'),
  fourHour('4 hours'),
  eightHour('8 hours'),
  oneDay('1 day');

  final String value;
  const NotificationInterval(this.value);
}

@JsonSerializable()
class NotificationProfile {
  @JsonKey(includeToJson: false)
  final String email;

  @JsonKey(name: 'allow_notifications')
  final bool allowNotifications;

  @JsonKey(name: 'notification_interval')
  final NotificationInterval notificationInterval;

  NotificationProfile(
      {this.email = '',
      this.allowNotifications = false,
      this.notificationInterval = NotificationInterval.oneHour});

  factory NotificationProfile.fromJson(Map<String, dynamic> json) =>
      _$NotificationProfileFromJson(json);

  NotificationProfile copyWith(
          {String? email,
          bool? allowNotifications,
          NotificationInterval? notificationInterval}) =>
      NotificationProfile(
          email: email ?? this.email,
          allowNotifications: allowNotifications ?? this.allowNotifications,
          notificationInterval:
              notificationInterval ?? this.notificationInterval);

  Map<String, dynamic> toJson() => _$NotificationProfileToJson(this);
}
