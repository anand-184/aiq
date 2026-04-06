class Branch {
  String? branchId;
  final String companyName;
  final String branchName;
  Branch({
    this.branchId,
    required this.companyName,
    required this.branchName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branchId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      branchName: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchId': branchId,
      'companyName': companyName,
      'name': branchName,
    };
  }

  Branch copyWith({
    String? branchId,
    String? companyName,
    String? name,
    String? timezone,
  }) {
    return Branch(
      branchId: branchId ?? this.branchId,
      companyName: companyName ?? this.companyName,
      branchName: name ?? this.branchName,
    );
  }
}
