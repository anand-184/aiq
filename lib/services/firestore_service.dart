import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/company.dart';
import '../models/payment_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Super Admin Methods ---
  Stream<List<Company>> getCompanies() {
    return _db.collection('companies').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Company.fromJson(doc.data());
      }).toList();
    });
  }
  Stream<UserModel> getUserDetails(String userId){
    return _db.collection('users').doc(userId).snapshots().map((doc){
      if (doc.exists && doc.data()!=null){
        return UserModel.fromJson(doc.data()!);
      }
      else{
        throw Exception("User not found");
      }

    });
  }

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

  Future<void> createCompany(Company company) {
    return _db
        .collection('companies')
        .doc(company.companyId)
        .set(company.toJson());
  }

  Future<void> deleteCompany(String companyId) {
    return _db.collection('companies').doc(companyId).delete();
  }

  Future<void> recordPayment(PaymentRecord payment) {
    return _db
        .collection('payments')
        .doc(payment.paymentId)
        .set(payment.toJson());
  }

  // --- Company Admin Methods ---

  // Get employees for a specific company
  Stream<List<UserModel>> getEmployees(String companyName) {
    return _db
        .collection('users')
        .where('companyName', isEqualTo: companyName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList());
  }

  // Get tasks for a specific company
  Stream<List<TaskModel>> getTasks(String companyId) {
    return _db
        .collection('tasks')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromJson(doc.data())).toList());
  }

  // Create a new task
  Future<void> createTask(TaskModel task) {
    return _db.collection('tasks').doc(task.taskId).set(task.toJson());
  }

  // Update a task
  Future<void> updateTask(TaskModel task) {
    return _db.collection('tasks').doc(task.taskId).update(task.toJson());
  }

  // Delete a task
  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }

  // Update user profile (role, skills, etc)
  Future<void> updateUser(UserModel user) {
    return _db.collection('users').doc(user.userId).update(user.toJson());
  }
}
