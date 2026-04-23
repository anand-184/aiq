import 'package:cloud_firestore/cloud_firestore.dart';
import 'converters.dart';

class PaymentRecord {
  final String paymentId;
  final String companyId;
  final String companyName;
  final double amount;
  final DateTime timestamp;
  final String status; // 'success', 'failed', 'pending'
  final String plan;

  PaymentRecord({
    required this.paymentId,
    required this.companyId,
    required this.companyName,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.plan,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      paymentId: json['paymentId'] as String? ?? '',
      companyId: json['companyId'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      timestamp: parseTimestamp(json['timestamp']),
      status: json['status'] as String? ?? 'pending',
      plan: json['plan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'companyId': companyId,
      'companyName': companyName,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'plan': plan,
    };
  }
}
