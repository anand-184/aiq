import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/company.dart';
import '../models/feedback_model.dart';
import '../models/performance_metric.dart';
import '../models/payment_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/branch.dart';

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

  Stream<UserModel> getUserDetails(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      } else {
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

  Future<void> updateCompanySettings(
      String companyId, Map<String, dynamic> settings) {
    return _db.collection('companies').doc(companyId).update({
      'settings': settings,
    });
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

  // Branches CRUD
  Stream<List<Branch>> getBranches(String companyName) {
    return _db
        .collection('branches')
        .where('companyName', isEqualTo: companyName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Branch.fromJson(doc.data())).toList());
  }

  Future<void> createBranch(Branch branch) {
    final docRef = _db.collection('branches').doc();
    final newBranch = branch.copyWith(branchId: docRef.id);
    return docRef.set(newBranch.toJson());
  }

  Future<void> updateBranch(Branch branch) {
    return _db
        .collection('branches')
        .doc(branch.branchId)
        .update(branch.toJson());
  }

  Future<void> deleteBranch(String branchId) {
    return _db.collection('branches').doc(branchId).delete();
  }

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
        .map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
      // Sort by dynamic priority descending
      tasks.sort((a, b) => b.dynamicPriorityScore.compareTo(a.dynamicPriorityScore));
      return tasks;
    });
  }

  Stream<List<TaskModel>> getTasksByAssignee(String userId) {
    return _db
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data()))
          .toList();
      // Sort by dynamic priority descending
      tasks.sort((a, b) => b.dynamicPriorityScore.compareTo(a.dynamicPriorityScore));
      return tasks;
    });
  }

  Stream<List<PerformanceMetric>> getPerformanceMetrics(String companyId) {
    return _db
        .collection('performance_metrics')
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PerformanceMetric.fromJson(doc.data()))
            .toList());
  }

  Future<void> recordPerformanceMetric(PerformanceMetric metric) {
    return _db
        .collection('performance_metrics')
        .doc(metric.metricId)
        .set(metric.toJson());
  }

  Stream<List<FeedbackModel>> getFeedback({String? companyId}) {
    Query<Map<String, dynamic>> query = _db.collection('feedback');
    if (companyId != null && companyId.isNotEmpty) {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots().map((snapshot) {
      final feedback =
          snapshot.docs.map((doc) => FeedbackModel.fromJson(doc.data())).toList();
      feedback.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return feedback;
    });
  }

  Future<void> createFeedback(FeedbackModel feedback) {
    return _db
        .collection('feedback')
        .doc(feedback.feedbackId)
        .set(feedback.toJson());
  }

  Future<void> updateFeedbackStatus(String feedbackId, String status) {
    return _db.collection('feedback').doc(feedbackId).update({
      'status': status,
    });
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
  /// Formula: Base Score + (Time Urgency) + (Progress Buffer)
  double calculateDynamicPriority(TaskModel task) {
    double score = 0.0;

    // 1. Base Priority Weight (Max 40)
    switch (task.basePriority.toLowerCase()) {
      case 'critical':
        score += 40.0;
        break;
      case 'high':
        score += 30.0;
        break;
      case 'medium':
        score += 20.0;
        break;
      case 'low':
        score += 10.0;
        break;
    }

    // 2. Time Urgency (Max 60)
    final now = DateTime.now();
    final timeRemaining = task.endTime.difference(now).inHours;

    if (timeRemaining <= 0) {
      score += 60.0; // Overdue
    } else if (timeRemaining < 4) {
      score += 50.0; // Due in < 4 hours
    } else if (timeRemaining < 24) {
      score += 30.0; // Due today
    } else if (timeRemaining < 72) {
      score += 15.0; // Due in 3 days
    }

    // 3. Progress Buffer
    if (task.status == 'In Progress') {
      score += 5.0;
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

  // Update a task and re-calculate priority
  Future<void> updateTask(TaskModel task) {
    final updatedTask = task.copyWith(
      dynamicPriorityScore: calculateDynamicPriority(task),
    );
    return _db.collection('tasks').doc(updatedTask.taskId).update(updatedTask.toJson());
  }

  // Delete a task
  Future<void> deleteTask(String taskId) {
    return _db.collection('tasks').doc(taskId).delete();
  }

  // Update user profile (role, skills, etc)
  Future<void> updateUser(UserModel user) {
    return _db.collection('users').doc(user.userId).update(user.toJson());
  }

  Future<void> deleteUser(String userId) {
    return _db.collection('users').doc(userId).delete();
  }
}
