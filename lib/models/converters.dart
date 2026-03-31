import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseTimestamp(dynamic value, {DateTime? fallback}) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  } else if (value is String) {
    return DateTime.parse(value);
  }
  return fallback ?? DateTime.now();
}

DateTime? parseOptionalTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  } else if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
