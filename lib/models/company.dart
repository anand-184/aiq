import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

class Company {
  final String companyId;
  final String name;
  final String ownerEmail;
  final String ownerName;
  final String plan;
  final int maxUsers;
  final bool isActive;
  final String? stripeCustomerId;
  final String? industry;
  final String? phoneNumber;
  final Map<String, dynamic> settings;
  final DateTime createdAt;

  Company({
    required this.companyId,
    required this.name,
    required this.ownerEmail,
    required this.ownerName,
    this.plan = 'Basic',
    this.maxUsers = 10,
    this.isActive = true,
    this.stripeCustomerId,
    this.industry,
    this.phoneNumber,
    this.settings = const {},
    required this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      ownerEmail: json['ownerEmail'] as String? ?? '',
      ownerName: json['ownerName'] as String? ?? '',
      plan: json['plan'] as String? ?? 'Basic',
      maxUsers: json['maxUsers'] as int? ?? 10,
      isActive: json['isActive'] as bool? ?? true,
      stripeCustomerId: json['stripeCustomerId'] as String?,
      industry: json['industry'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: parseTimestamp(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'name': name,
      'ownerEmail': ownerEmail,
      'ownerName': ownerName,
      'plan': plan,
      'maxUsers': maxUsers,
      'isActive': isActive,
      'stripeCustomerId': stripeCustomerId,
      'industry': industry,
      'phoneNumber': phoneNumber,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Company copyWith({
    String? companyId,
    String? name,
    String? ownerEmail,
    String? ownerName,
    String? plan,
    int? maxUsers,
    bool? isActive,
    String? stripeCustomerId,
    String? industry,
    String? phoneNumber,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
  }) {
    return Company(
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerName: ownerName ?? this.ownerName,
      plan: plan ?? this.plan,
      maxUsers: maxUsers ?? this.maxUsers,
      isActive: isActive ?? this.isActive,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      industry: industry ?? this.industry,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
