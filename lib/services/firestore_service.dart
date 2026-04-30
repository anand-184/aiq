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
  Stream<List<UserModel>> getEmployees(String companyId) {
    return _db
        .collection('users')
        .where('companyId', isEqualTo: companyId)
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

  // --- Scheduling Engine & Priority Logic ---

  /// Checks if the user has any overlapping tasks in the given time range.
  Future<bool> hasOverlappingTask(
      String userId, DateTime startTime, DateTime endTime) async {
    final snapshot = await _db
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .where('status', isNotEqualTo: 'Completed')
        .get();

    for (var doc in snapshot.docs) {
      final task = TaskModel.fromJson(doc.data());
      // Overlap logic: (StartA < EndB) and (EndA > StartB)
      if (startTime.isBefore(task.endTime) && endTime.isAfter(task.startTime)) {
        return true;
      }
    }
    return false;
  }

  /// Calculates the dynamic priority score for a task.
  /// Formula: Base Score + (Time Urgency) + (Dependencies)
  double calculateDynamicPriority(TaskModel task) {
    double score = 0.0;

    // 1. Base Priority
    switch (task.basePriority.toLowerCase()) {
      case 'high':
        score += 50.0;
        break;
      case 'medium':
        score += 30.0;
        break;
      case 'low':
        score += 10.0;
        break;
    }

    // 2. Time Urgency (Closer to deadline = higher score)
    final now = DateTime.now();
    final timeToDeadline = task.endTime.difference(now).inHours;

    if (timeToDeadline <= 0) {
      score += 50.0; // Overdue
    } else if (timeToDeadline < 24) {
      score += 40.0; // Critical (less than 1 day)
    } else if (timeToDeadline < 72) {
      score += 20.0; // High urgency (less than 3 days)
    }

    return score;
  }

  // Create a new task with scheduling check
  Future<String> createTask(TaskModel task) async {
    // 1. Check for overlaps
    bool isOverlapping = await hasOverlappingTask(
        task.assignedTo, task.startTime, task.endTime);
    if (isOverlapping) {
      return "Error: This employee already has a task assigned during this time slot.";
    }

    // 2. Calculate initial dynamic priority
    final dynamicTask =
        task.copyWith(dynamicPriorityScore: calculateDynamicPriority(task));

    await _db
        .collection('tasks')
        .doc(dynamicTask.taskId)
        .set(dynamicTask.toJson());
    return "success";
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
