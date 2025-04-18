import 'package:json_annotation/json_annotation.dart';

part 'qr_code_model.g.dart';

enum QRCodeType { patient, device, unknown }

abstract class QRCode {
  final QRCodeType codeType;

  QRCode([this.codeType = QRCodeType.unknown]);
}

@JsonSerializable()
class PatientQRCode extends QRCode {
  final String patientID;

  PatientQRCode({required this.patientID}) : super(QRCodeType.patient);

  factory PatientQRCode.fromJson(Map<String, dynamic> json) =>
      _$PatientQRCodeFromJson(json);

  @override
  String toString() {
    return 'PatientQRCode(QRCodeType: $codeType, patientID: $patientID)';
  }
}

@JsonSerializable()
class DeviceQRCode extends QRCode {
  final String deviceIP;

  DeviceQRCode({required this.deviceIP}) : super(QRCodeType.device);

  factory DeviceQRCode.fromJson(Map<String, dynamic> json) =>
      _$DeviceQRCodeFromJson(json);

  @override
  String toString() {
    return 'DeviceQRCode(QRCodeType: $codeType, deviceIP: $deviceIP)';
  }
}

@JsonSerializable()
class UnknownQRCode extends QRCode {
  UnknownQRCode() : super();

  factory UnknownQRCode.fromJson(Map<String, dynamic> json) =>
      _$UnknownQRCodeFromJson(json);

  @override
  String toString() {
    return 'UnknownQRCode(QRCodeType: $codeType)';
  }
}
