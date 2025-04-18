import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:witnessing_data_app/models/firebase/embryo_model.dart';
import 'package:witnessing_data_app/utilities/datetime_timestamp_conv.dart';

part 'patient_cycle_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PatientCycle {
  // Cycle Identifiers
  @JsonKey(name: "cycle_num", includeToJson: false)
  final int cycleNum;

  // Cycle Data
  @JsonKey(name: 'num_embryos')
  int numEmbryos;

  @JsonKey(
    name: "cycle_start_date",
    toJson: dateTimeToTimestamp,
    fromJson: timestampToDateTime,
  )
  final DateTime cycleStartDate;

  @JsonKey(
    name: "cycle_end_date",
    toJson: nullableDateTimeToTimestamp,
    fromJson: nullableTimestampToDateTime,
  )
  late DateTime? cycleEndDate;

  // Current active cycle data
  @JsonKey(includeToJson: false, includeFromJson: false)
  List<EmbryoData>? embryos;

  PatientCycle(
      {required this.cycleNum,
      this.embryos,
      required this.numEmbryos,
      required this.cycleStartDate,
      DateTime? endDate}) {
    cycleEndDate = endDate;
  }

  // JSON Converters for use with Firebase
  factory PatientCycle.fromJson(Map<String, dynamic> json) =>
      _$PatientCycleFromJson(json);
  Map<String, dynamic> toJson() => _$PatientCycleToJson(this);
}
