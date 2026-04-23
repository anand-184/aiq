import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';

class SuperAdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Pricing constants per user in ₹ (Rupees)
  static const double priceBasic = 250.0;
  static const double pricePro = 600.0;
  static const double priceEnterprise = 1200.0;
  
  // Platform operating cost (10%)
  static const double costPercentage = 0.10;

  // Streams
  Stream<List<Company>> get companiesStream => _firestoreService.getCompanies();
  Stream<List<PaymentRecord>> get paymentsStream => _firestoreService.getPayments();

  // Business Logic: Remove a company
  Future<void> removeCompany(String companyId) async {
    try {
      await _firestoreService.deleteCompany(companyId);
    } catch (e) {
      debugPrint("Error deleting company: $e");
    }
  }

  // Business Logic: Add a new company
  Future<void> addCompany({
    required String name,
    required String ownerEmail,
    required String ownerName,
    required String plan,
    required int maxUsers,
    String? industry,
    String? phoneNumber,
  }) async {
    final String companyId = DateTime.now().millisecondsSinceEpoch.toString();
    final newCompany = Company(
      companyId: companyId,
      name: name,
      ownerEmail: ownerEmail,
      ownerName: ownerName,
      plan: plan,
      maxUsers: maxUsers,
      isActive: true,
      industry: industry,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      settings: {},
    );

    try {
      await _firestoreService.createCompany(newCompany);
    } catch (e) {
      debugPrint("Error adding company: $e");
    }
  }

  Future<void> updateCompany(Company company) async {
    try {
      await _firestoreService.createCompany(company);
    } catch (e) {
      debugPrint("Error updating company: $e");
    }
  }

  // Revenue Calculation Helpers
  double calculateProjectedMonthlyRevenue(List<Company> companies) {
    double total = 0;
    for (var company in companies) {
      if (!company.isActive) continue;
      double pricePerUser = _getPriceForPlan(company.plan);
      total += (company.maxUsers * pricePerUser);
    }
    return total;
  }

  double calculateTotalActualRevenue(List<PaymentRecord> payments) {
    return payments
        .where((p) => p.status == 'success')
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  // 10% Calculation (Actual Costing)
  double calculateTotalCosts(double totalRevenue) {
    return totalRevenue * costPercentage;
  }

  double calculateNetProfit(double totalRevenue) {
    return totalRevenue * (1 - costPercentage);
  }

  double _getPriceForPlan(String plan) {
    switch (plan) {
      case 'Pro': return pricePro;
      case 'Enterprise': return priceEnterprise;
      case 'Basic':
      default: return priceBasic;
    }
  }

  // Manual payment recording for demo/admin purposes
  Future<void> recordManualPayment(Company company, double amount) async {
    final payment = PaymentRecord(
      paymentId: "PAY-${DateTime.now().millisecondsSinceEpoch}",
      companyId: company.companyId,
      companyName: company.name,
      amount: amount,
      timestamp: DateTime.now(),
      status: 'success',
      plan: company.plan,
    );
    await _firestoreService.recordPayment(payment);
  }
}
