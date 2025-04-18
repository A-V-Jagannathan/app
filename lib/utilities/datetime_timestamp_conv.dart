import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? nullableTimestampToDateTime(Timestamp? date) {
  return date?.toDate();
}

Timestamp? nullableDateTimeToTimestamp(DateTime? date) {
  return date == null ? null : Timestamp.fromDate(date);
}

DateTime timestampToDateTime(Timestamp date) {
  return date.toDate();
}

Timestamp dateTimeToTimestamp(DateTime date) {
  return Timestamp.fromDate(date);
}
