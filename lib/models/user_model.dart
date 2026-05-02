import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

class UserModel {
  final String userId;
  final String password;
  final String companyId;
  final String companyName;
  final String branchId;
  final String empId;
  final String name;
  final String email;
  final String role;
  final List<String> skills;
  final double maxCapacityHoursPerWeek;
  final double currentWorkloadPercentage;
  final Map<String, dynamic> googleCalendarTokens;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.password,
    required this.companyId,
    required this.companyName,
    required this.branchId,
    required this.empId,
    required this.name,
    required this.email,
    required this.role,
    this.skills = const [],
    required this.maxCapacityHoursPerWeek,
    this.currentWorkloadPercentage = 0.0,
    this.googleCalendarTokens = const {},
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String? ?? '',
      password: json['password'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      empId: json['empId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      maxCapacityHoursPerWeek: (json['maxCapacityHoursPerWeek'] as num?)?.toDouble() ?? 0.0,
      currentWorkloadPercentage: (json['currentWorkloadPercentage'] as num?)?.toDouble() ?? 0.0,
      googleCalendarTokens: json['googleCalendarTokens'] as Map<String, dynamic>? ?? {},
      createdAt: parseTimestamp(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'password': password,
      'companyId': companyId,
      'companyName': companyName,
      'branchId': branchId,
      'empId': empId,
      'name': name,
      'email': email,
      'role': role,
      'skills': skills,
      'maxCapacityHoursPerWeek': maxCapacityHoursPerWeek,
      'currentWorkloadPercentage': currentWorkloadPercentage,
      'googleCalendarTokens': googleCalendarTokens,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? userId,
    String? companyId,
    String? companyName,
    String? branchId,
    String? empId,
    String? name,
    String? email,
    String? role,
    List<String>? skills,
    double? maxCapacityHoursPerWeek,
    double? currentWorkloadPercentage,
    Map<String, dynamic>? googleCalendarTokens,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      password: password?? this.password,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      branchId: branchId ?? this.branchId,
      empId: empId ?? this.empId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      skills: skills ?? this.skills,
      maxCapacityHoursPerWeek: maxCapacityHoursPerWeek ?? this.maxCapacityHoursPerWeek,
      currentWorkloadPercentage: currentWorkloadPercentage ?? this.currentWorkloadPercentage,
      googleCalendarTokens: googleCalendarTokens ?? this.googleCalendarTokens,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
