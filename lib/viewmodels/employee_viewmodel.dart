import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../models/performance_metric.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class EmployeeViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<UserModel> get profileStream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.error("User not logged in");
    return _firestoreService.getUserDetails(uid);
  }

  Stream<List<TaskModel>> get myTasksStream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return _firestoreService.getTasksByAssignee(uid);
  }

  Stream<List<UserModel>> teamMembersStream(String companyId) {
    if (companyId.isEmpty) return Stream.value([]);
    return _firestoreService.getEmployees(companyId);
  }

  Stream<List<TaskModel>> teamTasksStream(String companyId) {
    if (companyId.isEmpty) return Stream.value([]);
    return _firestoreService.getTasks(companyId);
  }

  Future<String> assignTask({
    required String companyId,
    required String branchId,
    required String title,
    required String description,
    required String assignedTo,
    required DateTime startTime,
    required DateTime endTime,
    required String basePriority,
    List<String> requiredSkills = const [],
  }) async {
    final assignedBy = FirebaseAuth.instance.currentUser?.uid;
    if (assignedBy == null) return "Error: User not logged in.";
    if (companyId.isEmpty) return "Error: Company context not loaded.";
    if (assignedTo.isEmpty) return "Error: Please select an assignee.";
    if (!endTime.isAfter(startTime)) {
      return "Error: End time must be after start time.";
    }

    final taskId = "TASK-${DateTime.now().millisecondsSinceEpoch}";
    final task = TaskModel(
      taskId: taskId,
      companyId: companyId,
      branchId: branchId,
      title: title,
      description: description,
      requiredSkills: requiredSkills,
      assignedTo: assignedTo,
      assignedBy: assignedBy,
      startTime: startTime,
      endTime: endTime,
      estimatedDurationMinutes: endTime.difference(startTime).inMinutes,
      basePriority: basePriority,
      createdAt: DateTime.now(),
    );

    try {
      return await _firestoreService.createTask(task);
    } catch (e) {
      return "Error assigning task: $e";
    }
  }

  Future<void> updateTaskStatus(TaskModel task, String status) async {
    final updatedTask = task.copyWith(status: status);
    await _firestoreService.updateTask(updatedTask);
  }

  Future<void> submitTask({
    required TaskModel task,
    required String note,
    required String link,
  }) async {
    final submittedTask = task.copyWith(
      status: "Submitted",
      submissionNote: note,
      submissionLink: link,
      submittedAt: DateTime.now(),
    );
    await _firestoreService.updateTask(submittedTask);
  }

  Stream<List<FeedbackModel>> feedbackStream(String companyId) {
    return _firestoreService.getFeedback(companyId: companyId);
  }

  Future<void> submitFeedback({
    required UserModel user,
    required String category,
    required String message,
    required int rating,
  }) async {
    final feedback = FeedbackModel(
      feedbackId: "FDB-${DateTime.now().millisecondsSinceEpoch}",
      companyId: user.companyId,
      companyName: user.companyName,
      userId: user.userId,
      userName: user.name,
      role: user.role,
      category: category,
      message: message,
      rating: rating,
      createdAt: DateTime.now(),
    );
    await _firestoreService.createFeedback(feedback);
  }

  Future<void> updateProfile(UserModel user) async {
    await _firestoreService.updateUser(user);
  }

  Future<void> recordPerformanceSnapshot({
    required UserModel user,
    required int appScreenMinutes,
    required int focusMinutes,
    required int typedCharacters,
    required int correctionCount,
    required int taskSwitches,
  }) async {
    final activityScore = typedCharacters <= 0
        ? 0.0
        : ((typedCharacters - correctionCount).clamp(0, typedCharacters) /
                    typedCharacters *
                    100)
                .toDouble();
    final trackedMinutes = focusMinutes > 0 ? focusMinutes : appScreenMinutes;
    final keystrokesPerHour = trackedMinutes <= 0
        ? 0.0
        : typedCharacters / (trackedMinutes / 60.0);
    final metricId =
        "PERF-${user.userId}-${DateTime.now().millisecondsSinceEpoch}";
    final metric = PerformanceMetric(
      metricId: metricId,
      userId: user.userId,
      companyId: user.companyId,
      date: DateTime.now(),
      appScreenMinutes: appScreenMinutes,
      focusMinutes: focusMinutes,
      typedCharacters: typedCharacters,
      correctionCount: correctionCount,
      taskSwitches: taskSwitches,
      keystrokesPerHour: keystrokesPerHour,
      typingActivityScore: activityScore,
      employeeConsented: true,
    );
    await _firestoreService.recordPerformanceMetric(metric);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
