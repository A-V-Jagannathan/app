// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientData _$PatientDataFromJson(Map<String, dynamic> json) => PatientData(
      embryoscopeID: json['embryoscopeID'] as String,
      epicID: json['epic_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      dateOfBirth: timestampToDateTime(json['date_of_birth'] as Timestamp),
      totalNumCycles: (json['total_num_cycles'] as num).toInt(),
      currentCycleNum: (json['current_cycle_num'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$PatientDataToJson(PatientData instance) =>
    <String, dynamic>{
      'epic_id': instance.epicID,
      'total_num_cycles': instance.totalNumCycles,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'date_of_birth': dateTimeToTimestamp(instance.dateOfBirth),
      'current_cycle_num': instance.currentCycleNum,
    };
