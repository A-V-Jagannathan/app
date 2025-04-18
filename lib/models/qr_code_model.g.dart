// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientQRCode _$PatientQRCodeFromJson(Map<String, dynamic> json) =>
    PatientQRCode(
      patientID: json['patientID'] as String,
    );

Map<String, dynamic> _$PatientQRCodeToJson(PatientQRCode instance) =>
    <String, dynamic>{
      'patientID': instance.patientID,
    };

DeviceQRCode _$DeviceQRCodeFromJson(Map<String, dynamic> json) => DeviceQRCode(
      deviceIP: json['deviceIP'] as String,
    );

Map<String, dynamic> _$DeviceQRCodeToJson(DeviceQRCode instance) =>
    <String, dynamic>{
      'deviceIP': instance.deviceIP,
    };

UnknownQRCode _$UnknownQRCodeFromJson(Map<String, dynamic> json) =>
    UnknownQRCode();

Map<String, dynamic> _$UnknownQRCodeToJson(UnknownQRCode instance) =>
    <String, dynamic>{};
