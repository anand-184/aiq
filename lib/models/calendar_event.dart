import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

class CalendarEvent {
  final String eventId;
  final String companyId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final String type;
  final String? referenceId;

  CalendarEvent({
    required this.eventId,
    required this.companyId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.referenceId,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['eventId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      startTime: parseTimestamp(json['startTime']),
      endTime: parseTimestamp(json['endTime']),
      type: json['type'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'companyId': companyId,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'type': type,
      'referenceId': referenceId,
    };
  }

  CalendarEvent copyWith({
    String? eventId,
    String? companyId,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    String? type,
    String? referenceId,
  }) {
    return CalendarEvent(
      eventId: eventId ?? this.eventId,
      companyId: companyId ?? this.companyId,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
    );
  }
}
