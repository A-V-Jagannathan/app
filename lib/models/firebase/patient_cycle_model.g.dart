// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_cycle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PatientCycle _$PatientCycleFromJson(Map<String, dynamic> json) => PatientCycle(
      cycleNum: (json['cycle_num'] as num).toInt(),
      numEmbryos: (json['num_embryos'] as num).toInt(),
      cycleStartDate:
          timestampToDateTime(json['cycle_start_date'] as Timestamp),
    )..cycleEndDate =
        nullableTimestampToDateTime(json['cycle_end_date'] as Timestamp?);

Map<String, dynamic> _$PatientCycleToJson(PatientCycle instance) =>
    <String, dynamic>{
      'num_embryos': instance.numEmbryos,
      'cycle_start_date': dateTimeToTimestamp(instance.cycleStartDate),
      'cycle_end_date': nullableDateTimeToTimestamp(instance.cycleEndDate),
    };
