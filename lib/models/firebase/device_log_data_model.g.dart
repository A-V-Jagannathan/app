// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_log_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceLogRecord _$DeviceLogRecordFromJson(Map<String, dynamic> json) =>
    DeviceLogRecord(
      event: $enumDecode(_$DeviceLogEventEnumMap, json['event']),
      message: json['message'] as String,
      timestamp: timestampToDateTime(json['timestamp'] as Timestamp),
    );

Map<String, dynamic> _$DeviceLogRecordToJson(DeviceLogRecord instance) =>
    <String, dynamic>{
      'event': _$DeviceLogEventEnumMap[instance.event]!,
      'timestamp': dateTimeToTimestamp(instance.timestamp),
      'message': instance.message,
    };

const _$DeviceLogEventEnumMap = {
  DeviceLogEvent.disconnect: 'disconnect',
  DeviceLogEvent.connect: 'connect',
  DeviceLogEvent.recordStart: 'recordStart',
  DeviceLogEvent.recordStop: 'recordStop',
  DeviceLogEvent.embryoSelection: 'embryoSelection',
};
