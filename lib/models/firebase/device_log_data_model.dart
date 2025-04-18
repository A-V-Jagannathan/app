import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:witnessing_data_app/utilities/datetime_timestamp_conv.dart';

part 'device_log_data_model.g.dart';

enum DeviceLogEvent {
  disconnect,
  connect,
  recordStart,
  recordStop,
  embryoSelection
}

@JsonSerializable()
class DeviceLogRecord {
  DeviceLogRecord(
      {required this.event, required this.message, required this.timestamp});

  final DeviceLogEvent event;

  @JsonKey(fromJson: timestampToDateTime, toJson: dateTimeToTimestamp)
  final DateTime timestamp;

  final String message;

  factory DeviceLogRecord.fromJson(Map<String, dynamic> json) =>
      _$DeviceLogRecordFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceLogRecordToJson(this);

  @override
  String toString() {
    return 'DeviceLogRecord{event: $event, timestamp: $timestamp, message: $message}';
  }
}
