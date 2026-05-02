import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> updateTaskStatus(TaskModel task, String status) async {
    final updatedTask = task.copyWith(status: status);
    await _firestoreService.updateTask(updatedTask);
  }
}
