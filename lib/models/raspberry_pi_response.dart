import 'package:json_annotation/json_annotation.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';

part 'raspberry_pi_response.g.dart';

@JsonSerializable()
class RPiResponse {
  @JsonKey(includeFromJson: false, includeToJson: false)
  int statusCode;
  final DeviceStatus status;
  final String message;
  final dynamic data;
  final dynamic error;

  RPiResponse({
    this.statusCode = 200,
    required this.status,
    required this.message,
    this.data,
    this.error,
  });

  factory RPiResponse.fromJson(Map<String, dynamic> json) =>
      _$RPiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RPiResponseToJson(this);
}
