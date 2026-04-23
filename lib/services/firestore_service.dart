import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company.dart';
import '../models/payment_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of all companies
  Stream<List<Company>> getCompanies() {
    return _db.collection('companies').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Company.fromJson(doc.data());
      }).toList();
    });
  }

  // Stream of all payments
  Stream<List<PaymentRecord>> getPayments() {
    return _db
        .collection('payments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PaymentRecord.fromJson(doc.data());
      }).toList();
    });
  }

  // Create or Update a company
  Future<void> createCompany(Company company) {
    return _db
        .collection('companies')
        .doc(company.companyId)
        .set(company.toJson());
  }

  // Delete a company
  Future<void> deleteCompany(String companyId) {
    return _db.collection('companies').doc(companyId).delete();
  }

  // Record a payment
  Future<void> recordPayment(PaymentRecord payment) {
    return _db
        .collection('payments')
        .doc(payment.paymentId)
        .set(payment.toJson());
  }
}
