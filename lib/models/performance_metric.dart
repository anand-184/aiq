import 'package:cloud_firestore/cloud_firestore.dart';

import 'converters.dart';

class PerformanceMetric {
  final String metricId;
  final String userId;
  final String companyId;
  final DateTime date;
  final int appScreenMinutes;
  final int focusMinutes;
  final int taskSwitches;
  final int typedCharacters;
  final int correctionCount;
  final double keystrokesPerHour;
  final double typingActivityScore;
  final bool employeeConsented;

  PerformanceMetric({
    required this.metricId,
    required this.userId,
    required this.companyId,
    required this.date,
    this.appScreenMinutes = 0,
    this.focusMinutes = 0,
    this.taskSwitches = 0,
    this.typedCharacters = 0,
    this.correctionCount = 0,
    this.keystrokesPerHour = 0,
    this.typingActivityScore = 0,
    this.employeeConsented = false,
  });

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) {
    return PerformanceMetric(
      metricId: json['metricId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      date: parseTimestamp(json['date']),
      appScreenMinutes: (json['appScreenMinutes'] as num?)?.toInt() ?? 0,
      focusMinutes: (json['focusMinutes'] as num?)?.toInt() ?? 0,
      taskSwitches: (json['taskSwitches'] as num?)?.toInt() ?? 0,
      typedCharacters: (json['typedCharacters'] as num?)?.toInt() ?? 0,
      correctionCount: (json['correctionCount'] as num?)?.toInt() ?? 0,
      keystrokesPerHour:
          (json['keystrokesPerHour'] as num?)?.toDouble() ?? 0,
      typingActivityScore:
          (json['typingActivityScore'] as num?)?.toDouble() ?? 0,
      employeeConsented: json['employeeConsented'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metricId': metricId,
      'userId': userId,
      'companyId': companyId,
      'date': Timestamp.fromDate(date),
      'appScreenMinutes': appScreenMinutes,
      'focusMinutes': focusMinutes,
      'taskSwitches': taskSwitches,
      'typedCharacters': typedCharacters,
      'correctionCount': correctionCount,
      'keystrokesPerHour': keystrokesPerHour,
      'typingActivityScore': typingActivityScore,
      'employeeConsented': employeeConsented,
    };
  }
}
