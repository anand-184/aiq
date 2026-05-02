import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // These would typically come from an Auth service after login
  String? currentCompanyId;
  String? currentCompanyName;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  TimeOfDay startHour = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endHour = const TimeOfDay(hour: 18, minute: 0);

  void updateWorkingHours(TimeOfDay start, TimeOfDay end) async {
    startHour = start;
    endHour = end;
    notifyListeners();

    if (currentCompanyId != null) {
      await _firestoreService.updateCompanySettings(currentCompanyId!, {
        'startHour': start.hour,
        'startMinute': start.minute,
        'endHour': end.hour,
        'endMinute': end.minute,
      });
    }
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

    return _firestoreService.getUserDetails(uid).map((user) {
      // Automatically set context when profile is loaded
      currentCompanyId = user.companyId;
      currentCompanyName = user.companyName;
      return user;
    });
  }

  // Streams
  Stream<List<UserModel>> get employeesStream {
    if (currentCompanyId == null) return const Stream.empty();
    return _firestoreService.getEmployees(currentCompanyId!);
  }

  Stream<List<TaskModel>> get tasksStream {
    if (currentCompanyId == null) return const Stream.empty();
    return _firestoreService.getTasks(currentCompanyId!);
  }

  Stream<List<Branch>> get branchesStream {
    if (currentCompanyName == null) return const Stream.empty();
    return _firestoreService.getBranches(currentCompanyName!);
  }

  // Branch CRUD
  Future<void> addBranch(String name) async {
    if (currentCompanyName == null) return;
    final branch = Branch(
      companyName: currentCompanyName!,
      branchName: name,
    );
    await _firestoreService.createBranch(branch);
  }

  Future<void> updateBranch(Branch branch) async {
    await _firestoreService.updateBranch(branch);
  }

  Future<void> removeBranch(String branchId) async {
    await _firestoreService.deleteBranch(branchId);
  }

  // Task CRUD
  Future<String> addTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime startTime,
    required DateTime endTime,
    required String basePriority,
    required String branchId,
    required String assignedBy,
  }) async {
    if (currentCompanyId == null) return "Error: No company context found.";

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
      return await _firestoreService.createTask(newTask);
    } catch (e) {
      debugPrint("Error adding task: $e");
      return "Error adding task: $e";
    }
  }

  Future<void> updateTask(TaskModel task) async {
    await _firestoreService.updateTask(task);
  }

  Future<void> updateTaskStatus(TaskModel task, String newStatus) async {
    final updatedTask = task.copyWith(status: newStatus);
    await _firestoreService.updateTask(updatedTask);
  }

  Future<void> removeTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }

  Future<void> removeEmployee(UserModel user) async {
    await _firestoreService.deleteUser(user.userId);
  }

  Future<void> updateEmployee(UserModel user) async {
    await _firestoreService.updateUser(user);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
