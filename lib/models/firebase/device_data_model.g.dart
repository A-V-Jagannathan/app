// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceData _$DeviceDataFromJson(Map<String, dynamic> json) => DeviceData(
      name: json['name'] as String,
      ipAddress: DeviceData._ipAddressFromJson(json['ipAddress'] as String),
      status: $enumDecodeNullable(_$DeviceStatusEnumMap, json['status']) ??
          DeviceStatus.disconnected,
    );

Map<String, dynamic> _$DeviceDataToJson(DeviceData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'ipAddress': DeviceData._ipAddressToJson(instance.ipAddress),
      'status': _$DeviceStatusEnumMap[instance.status]!,
    };

const _$DeviceStatusEnumMap = {
  DeviceStatus.connected: 'connected',
  DeviceStatus.disconnected: 'disconnected',
  DeviceStatus.recording: 'recording',
  DeviceStatus.previewing: 'previewing',
};
