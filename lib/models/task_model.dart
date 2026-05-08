import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

class TaskModel {
  final String taskId;
  final String companyId;
  final String branchId;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String assignedTo;
  final String assignedBy;
  final DateTime startTime;
  final DateTime endTime;
  final int estimatedDurationMinutes;
  final String basePriority;
  final double dynamicPriorityScore;
  final String status;
  final String? googleEventId;
  final String submissionNote;
  final String submissionLink;
  final DateTime? submittedAt;
  final String reviewerFeedback;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  TaskModel({
    required this.taskId,
    required this.companyId,
    required this.branchId,
    required this.title,
    required this.description,
    this.requiredSkills = const [],
    required this.assignedTo,
    required this.assignedBy,
    required this.startTime,
    required this.endTime,
    required this.estimatedDurationMinutes,
    required this.basePriority,
    this.dynamicPriorityScore = 0.0,
    this.status = 'Pending',
    this.googleEventId,
    this.submissionNote = '',
    this.submissionLink = '',
    this.submittedAt,
    this.reviewerFeedback = '',
    this.reviewedAt,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: json['taskId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      requiredSkills: (json['requiredSkills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      assignedTo: json['assignedTo'] as String? ?? '',
      assignedBy: json['assignedBy'] as String? ?? '',
      startTime: parseTimestamp(json['startTime']),
      endTime: parseTimestamp(json['endTime']),
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)?.toInt() ?? 0,
      basePriority: json['basePriority'] as String? ?? '',
      dynamicPriorityScore: (json['dynamicPriorityScore'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Pending',
      googleEventId: json['googleEventId'] as String?,
      submissionNote: json['submissionNote'] as String? ?? '',
      submissionLink: json['submissionLink'] as String? ?? '',
      submittedAt:
          json['submittedAt'] == null ? null : parseTimestamp(json['submittedAt']),
      reviewerFeedback: json['reviewerFeedback'] as String? ?? '',
      reviewedAt:
          json['reviewedAt'] == null ? null : parseTimestamp(json['reviewedAt']),
      createdAt: parseTimestamp(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'companyId': companyId,
      'branchId': branchId,
      'title': title,
      'description': description,
      'requiredSkills': requiredSkills,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'basePriority': basePriority,
      'dynamicPriorityScore': dynamicPriorityScore,
      'status': status,
      'googleEventId': googleEventId,
      'submissionNote': submissionNote,
      'submissionLink': submissionLink,
      'submittedAt': submittedAt == null ? null : Timestamp.fromDate(submittedAt!),
      'reviewerFeedback': reviewerFeedback,
      'reviewedAt': reviewedAt == null ? null : Timestamp.fromDate(reviewedAt!),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TaskModel copyWith({
    String? taskId,
    String? companyId,
    String? branchId,
    String? title,
    String? description,
    List<String>? requiredSkills,
    String? assignedTo,
    String? assignedBy,
    DateTime? startTime,
    DateTime? endTime,
    int? estimatedDurationMinutes,
    String? basePriority,
    double? dynamicPriorityScore,
    String? status,
    String? googleEventId,
    String? submissionNote,
    String? submissionLink,
    DateTime? submittedAt,
    String? reviewerFeedback,
    DateTime? reviewedAt,
    DateTime? createdAt,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      companyId: companyId ?? this.companyId,
      branchId: branchId ?? this.branchId,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      basePriority: basePriority ?? this.basePriority,
      dynamicPriorityScore: dynamicPriorityScore ?? this.dynamicPriorityScore,
      status: status ?? this.status,
      googleEventId: googleEventId ?? this.googleEventId,
      submissionNote: submissionNote ?? this.submissionNote,
      submissionLink: submissionLink ?? this.submissionLink,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewerFeedback: reviewerFeedback ?? this.reviewerFeedback,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
