import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:witnessing_data_app/models/firebase/patient_cycle_model.dart';
import 'package:witnessing_data_app/utilities/datetime_timestamp_conv.dart';

part 'patient_data_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PatientData {
  // Patient Identifiers
  @JsonKey(includeToJson: false)
  final String embryoscopeID;

  @JsonKey(name: 'epic_id')
  final String epicID;

  @JsonKey(name: 'total_num_cycles')
  int totalNumCycles;

  // Patient Personal Information
  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  @JsonKey(
      name: 'date_of_birth',
      toJson: dateTimeToTimestamp,
      fromJson: timestampToDateTime)
  final DateTime dateOfBirth;

  // Currently active patient data
  @JsonKey(name: 'current_cycle_num')
  int currentCycleNum;

  @JsonKey(includeToJson: false, includeFromJson: false)
  List<PatientCycle>? cycles;

  PatientData({
    required this.embryoscopeID,
    required this.epicID,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.cycles,
    required this.totalNumCycles,
    this.currentCycleNum = 0,
  });

  PatientData copyWith({
    int? totalNumCycles,
    int? currentCycleNum,
    List<PatientCycle>? cycles,
  }) {
    return PatientData(
      embryoscopeID: embryoscopeID,
      epicID: epicID,
      totalNumCycles: totalNumCycles ?? this.totalNumCycles,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      currentCycleNum: currentCycleNum ?? this.currentCycleNum,
      cycles: cycles ?? this.cycles,
    );
  }

  factory PatientData.fromJson(Map<String, dynamic> json) =>
      _$PatientDataFromJson(json);

  Map<String, dynamic> toJson() => _$PatientDataToJson(this);
}
