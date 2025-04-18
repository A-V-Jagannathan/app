// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raspberry_pi_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RPiResponse _$RPiResponseFromJson(Map<String, dynamic> json) => RPiResponse(
      status: $enumDecode(_$DeviceStatusEnumMap, json['status']),
      message: json['message'] as String,
      data: json['data'],
      error: json['error'],
    );

Map<String, dynamic> _$RPiResponseToJson(RPiResponse instance) =>
    <String, dynamic>{
      'status': _$DeviceStatusEnumMap[instance.status]!,
      'message': instance.message,
      'data': instance.data,
      'error': instance.error,
    };

const _$DeviceStatusEnumMap = {
  DeviceStatus.connected: 'connected',
  DeviceStatus.disconnected: 'disconnected',
  DeviceStatus.recording: 'recording',
  DeviceStatus.previewing: 'previewing',
};
