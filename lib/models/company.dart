import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

class Company {
  final String companyId;
  final String name;
  final Map<String, dynamic> settings;
  final DateTime createdAt;

  Company({
    required this.companyId,
    required this.name,
    this.settings = const {},
    required this.createdAt,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: parseTimestamp(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'name': name,
      'settings': settings,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Company copyWith({
    String? companyId,
    String? name,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
  }) {
    return Company(
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
