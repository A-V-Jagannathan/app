import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:witnessing_data_app/utilities/datetime_timestamp_conv.dart';

part 'embryo_model.g.dart';

@JsonSerializable()
class EmbryoData {
  @JsonKey(name: 'embryo_number')
  final int embryoNumber;

  @JsonKey(includeToJson: false)
  String id;
  @JsonKey(
      fromJson: nullableTimestampToDateTime,
      toJson: nullableDateTimeToTimestamp)
  final DateTime? date;
  final String? stage;
  final String? grade;

  EmbryoData(
      {required this.id,
      required this.embryoNumber,
      this.date,
      this.stage,
      this.grade});

  factory EmbryoData.fromJson(Map<String, dynamic> json) =>
      _$EmbryoDataFromJson(json);

  Map<String, dynamic> toJson() => _$EmbryoDataToJson(this);

  // static DateTime? _dateTimeFromTimestamp(Timestamp? date) {
  //   return date?.toDate();
  // }

  // static Timestamp? _dateTimeToTimestamp(DateTime? date) {
  //   return date == null ? null : Timestamp.fromDate(date);
  // }

  @override
  String toString() {
    return 'EmbryoData{embryoNumber: $embryoNumber, id: $id, date: $date, stage: $stage, grade: $grade}';
  }
}
