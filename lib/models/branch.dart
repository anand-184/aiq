class Branch {
  final String branchId;
  final String companyId;
  final String name;
  final String timezone;

  Branch({
    required this.branchId,
    required this.companyId,
    required this.name,
    required this.timezone,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branchId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      timezone: json['timezone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'companyId': companyId,
      'name': name,
      'timezone': timezone,
    };
  }

  Branch copyWith({
    String? branchId,
    String? companyId,
    String? name,
    String? timezone,
  }) {
    return Branch(
      branchId: branchId ?? this.branchId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      timezone: timezone ?? this.timezone,
    );
  }
}
