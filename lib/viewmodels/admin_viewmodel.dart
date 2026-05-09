import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/branch.dart';
import '../models/performance_metric.dart';
import '../models/feedback_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // These would typically come from an Auth service after login
  String? currentCompanyId;
  String? currentCompanyName;
  String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  TimeOfDay startHour = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endHour = const TimeOfDay(hour: 18, minute: 0);
  List<UserModel> _lastFetchedEmployees = [];
  List<UserModel> get currentEmployees => _lastFetchedEmployees;

  AdminViewModel() {
    _initializeContext();
  }

  void _initializeContext() {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      _firestoreService
          .getUserDetails(uid)
          .listen(
            (user) {
              currentCompanyId = user.companyId;
              currentCompanyName = user.companyName;
              notifyListeners();
            },
            onError: (e) {
              debugPrint("Error initializing AdminViewModel: $e");
            },
          );
    }
  }

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
    return _firestoreService.getEmployees(currentCompanyId!).map((list) {
      _lastFetchedEmployees = list;
      return list;
    });
  }

  Stream<List<TaskModel>> get tasksStream {
    if (currentCompanyId == null) return const Stream.empty();
    return _firestoreService.getTasks(currentCompanyId!);
  }

  Stream<List<Branch>> get branchesStream {
    if (currentCompanyName == null) return const Stream.empty();
    return _firestoreService.getBranches(currentCompanyName!);
  }

  Stream<List<PerformanceMetric>> get performanceMetricsStream {
    if (currentCompanyId == null) return const Stream.empty();
    return _firestoreService.getPerformanceMetrics(currentCompanyId!);
  }

  Stream<List<FeedbackModel>> get feedbackStream {
    if (currentCompanyId == null) return const Stream.empty();
    return _firestoreService.getFeedback(companyId: currentCompanyId!);
  }

  // Branch CRUD
  Future<String> addBranch(String name) async {
    if (currentCompanyName == null) {
      return "Error: Company context not loaded yet.";
    }
    final branch = Branch(companyName: currentCompanyName!, branchName: name);
    try {
      await _firestoreService.createBranch(branch);
      return "success";
    } catch (e) {
      return "Error: $e";
    }
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

  Future<void> reviewTaskSubmission(
    TaskModel task, {
    required bool approved,
    required String feedback,
  }) async {
    final reviewedTask = task.copyWith(
      status: approved ? "Completed" : "Pending",
      reviewerFeedback: feedback,
      reviewedAt: DateTime.now(),
    );
    await _firestoreService.updateTask(reviewedTask);
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

  Future<void> removeTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }

  Future<void> removeEmployee(UserModel user) async {
    await _firestoreService.deleteUser(user.userId);
  }

  Future<void> updateEmployee(UserModel user) async {
    await _firestoreService.updateUser(user);
  }

  Future<String> addEmployee({
    required String email,
    required String password,
    required String name,
    required String role,
    required String branchId,
    required List<String> skills,
  }) async {
    if (currentCompanyId == null || currentCompanyName == null) {
      return "Error: Company context not set. Please wait for profile to load.";
    }

    try {
      final uid = await AuthService().registerUserInBackground(
        email: email,
        password: password,
        name: name,
        companyId: currentCompanyId!,
        companyName: currentCompanyName!,
        role: role,
        branchId: branchId,
        skills: skills,
      );
      return uid != null ? "success" : "Error: Failed to create user.";
    } catch (e) {
      debugPrint("Error adding employee: $e");
      return "Error: $e";
    }
  }

  Map<String, dynamic> calculateEmployeeStats(
    String userId,
    List<TaskModel> allTasks,
  ) {
    final userTasks = allTasks.where((t) => t.assignedTo == userId).toList();

    int completed = userTasks.where((t) => t.status == 'Completed').length;
    int inProgress = userTasks.where((t) => t.status == 'In Progress').length;
    int pending = userTasks.where((t) => t.status == 'Pending').length;
    int submitted = userTasks.where((t) => t.status == 'Submitted').length;

    double completionRate = userTasks.isEmpty
        ? 0.0
        : (completed / userTasks.length) * 100;

    return {
      'total': userTasks.length,
      'completed': completed,
      'inProgress': inProgress,
      'pending': pending,
      'submitted': submitted,
      'completionRate': completionRate,
      'tasks': userTasks,
    };
  }

  double calculateWorkloadPercentage(UserModel user, List<TaskModel> tasks) {
    final capacityMinutes =
        (user.maxCapacityHoursPerWeek <= 0
            ? 40
            : user.maxCapacityHoursPerWeek) *
        60;
    final activeMinutes = tasks
        .where(
          (task) =>
              task.assignedTo == user.userId && task.status != "Completed",
        )
        .fold<int>(0, (total, task) {
          if (task.estimatedDurationMinutes > 0) {
            return total + task.estimatedDurationMinutes;
          }
          final minutes = task.endTime.difference(task.startTime).inMinutes;
          return total + minutes.clamp(0, 24 * 60);
        });
    return (activeMinutes / capacityMinutes * 100).clamp(0, 100).toDouble();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
