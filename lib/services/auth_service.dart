import 'package:aiq/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  Future<void> registerUser({
    required String email,
    required String password,
    required String companyName,
    required String branchId,
    required String empId,
    required String name,
    required String phone,
    required String role,
    List<String> skills = const [],
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        UserModel userModel = UserModel(
            userId: user.uid,
            companyName: companyName,
            branchId: branchId,
            empId: empId,
            name: name,
            email: email,
            role: role,
            maxCapacityHoursPerWeek: 0,
            createdAt: DateTime.now(),
            skills: skills,
            googleCalendarTokens: {},
            currentWorkloadPercentage: 0.0);
        await fireStore
            .collection("users")
            .doc(user.uid)
            .set(userModel.toJson());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        debugPrint("The password provided is too weak");
      } else if (e.code == "email-already-in-use") {
        debugPrint("The account already exists for that email");
      }
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception("Failed to register user : $e");
    }
  }

  Future<String> loginUser(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        return "success";
      } else {
        return "Unknown error: User is null after login";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        return "No user found for that email";
      } else if (e.code == "wrong-password") {
        return "Wrong password provided";
      } else if (e.code == "invalid-credential") {
        return "Invalid email or password";
      } else if (e.code == "user-disabled") {
        return "This user account has been disabled";
      }
      return e.message ?? "Authentication failed";
    } catch (e) {
      return e.toString();
    }
  }
}
