// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embryo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmbryoData _$EmbryoDataFromJson(Map<String, dynamic> json) => EmbryoData(
      id: json['id'] as String,
      embryoNumber: (json['embryo_number'] as num).toInt(),
      date: nullableTimestampToDateTime(json['date'] as Timestamp?),
      stage: json['stage'] as String?,
      grade: json['grade'] as String?,
    );

Map<String, dynamic> _$EmbryoDataToJson(EmbryoData instance) =>
    <String, dynamic>{
      'embryo_number': instance.embryoNumber,
      'date': nullableDateTimeToTimestamp(instance.date),
      'stage': instance.stage,
      'grade': instance.grade,
    };
