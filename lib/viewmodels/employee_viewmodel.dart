import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      typingActivityScore: activityScore,
      employeeConsented: true,
    );
    await _firestoreService.recordPerformanceMetric(metric);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
