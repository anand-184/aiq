import 'package:cloud_firestore/cloud_firestore.dart';

import 'converters.dart';

class FeedbackModel {
  final String feedbackId;
  final String companyId;
  final String companyName;
  final String userId;
  final String userName;
  final String role;
  final String category;
  final String message;
  final int rating;
  final String status;
  final DateTime createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.companyId,
    required this.companyName,
    required this.userId,
    required this.userName,
    required this.role,
    required this.category,
    required this.message,
    required this.rating,
    this.status = "Open",
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      message: json['message'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 3,
      status: json['status'] as String? ?? 'Open',
      createdAt: parseTimestamp(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'companyId': companyId,
      'companyName': companyName,
      'userId': userId,
      'userName': userName,
      'role': role,
      'category': category,
      'message': message,
      'rating': rating,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  FeedbackModel copyWith({String? status}) {
    return FeedbackModel(
      feedbackId: feedbackId,
      companyId: companyId,
      companyName: companyName,
      userId: userId,
      userName: userName,
      role: role,
      category: category,
      message: message,
      rating: rating,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
