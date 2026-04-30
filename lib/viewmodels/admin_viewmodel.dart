import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AIService _aiService = AIService();
  
  // These would typically come from an Auth service after login
  String? currentCompanyId;
  String? currentCompanyName;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  TimeOfDay startHour = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endHour = const TimeOfDay(hour: 6, minute: 0);

  List<Map<String, dynamic>> smartRecommendations = [];
  bool isLoadingRecommendations = false;

  void updateWorkingHours(TimeOfDay start, TimeOfDay end){
    startHour = start;
    endHour= end;
    notifyListeners();
  }

  Future<void> getAIRecommendations({
    required List<String> requiredSkills,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (currentCompanyId == null) return;
    
    isLoadingRecommendations = true;
    notifyListeners();

    try {
      smartRecommendations = await _aiService.getSmartRecommendations(
        companyId: currentCompanyId!,
        requiredSkills: requiredSkills,
        startTime: startTime,
        endTime: endTime,
      );
    } catch (e) {
      debugPrint("AI Error: $e");
    } finally {
      isLoadingRecommendations = false;
      notifyListeners();
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

  Future<String> addTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime startTime,
    required DateTime endTime,
    required String basePriority,
    required String branchId,
    required String assignedBy,
    List<String> requiredSkills = const [],
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
      requiredSkills: requiredSkills,
      createdAt: DateTime.now(),
    );

    try {
      return await _firestoreService.createTask(newTask);
    } catch (e) {
      debugPrint("Error adding task: $e");
      return "Error adding task: $e";
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
