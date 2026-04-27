import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  // These would typically come from an Auth service after login
  String? currentCompanyId;
  String? currentCompanyName;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  TimeOfDay startHour = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endHour = const TimeOfDay(hour: 6, minute: 0);

  void updateWorkingHours(TimeOfDay start, TimeOfDay end){
    startHour = start;
        endHour= end;
        notifyListeners();
  }

  void setCompanyContext(String companyId, String companyName) {
    currentCompanyId = companyId;
    currentCompanyName = companyName;
    notifyListeners();
  }

  Stream<UserModel> get AdminProfile {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.error("User not authenticated");
    }
    return _firestoreService.getUserDetails(uid);
  }

  // Streams
  Stream<List<UserModel>> get employeesStream {
    if (currentCompanyName == null) return const Stream.empty();
    return _firestoreService.getEmployees(currentCompanyName!);
  }

  Stream<List<TaskModel>> get tasksStream {
    if (currentCompanyId == null) return const Stream.empty();
    return _firestoreService.getTasks(currentCompanyId!);
  }


  Future<void> addTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime startTime,
    required DateTime endTime,
    required String basePriority,
    required String branchId,
    required String assignedBy,
  }) async {
    if (currentCompanyId == null) return;

    final String taskId = "TASK-${DateTime.now().millisecondsSinceEpoch}";
    final newTask = TaskModel(
      taskId: taskId,
      companyId: currentCompanyId!,
      branchId: branchId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedBy: assignedBy,
      startTime: startTime,
      endTime: endTime,
      estimatedDurationMinutes: endTime.difference(startTime).inMinutes,
      basePriority: basePriority,
      createdAt: DateTime.now(),
    );

    try {
      await _firestoreService.createTask(newTask);
    } catch (e) {
      debugPrint("Error adding task: $e");
    }
  }

  Future<void> updateTaskStatus(TaskModel task, String newStatus) async {
    final updatedTask = task.copyWith(status: newStatus);
    await _firestoreService.updateTask(updatedTask);
  }

  Future<void> removeTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }
}
