import 'dart:convert';
import 'package:aiq/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Registers a user in the background without signing out the current user.
  Future<String?> registerUserInBackground({
    required String email,
    required String password,
    required String name,
    required String companyId,
    required String companyName,
    required String role,
    required String branchId,
    List<String> skills = const [],
    double maxCapacity = 40.0,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedRole = role.trim().isEmpty ? "Employee" : role.trim();
    String tempAppName = 'TempApp_${DateTime.now().millisecondsSinceEpoch}';
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: tempAppName,
      options: Firebase.app().options,
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instanceFor(app: tempApp)
              .createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      
      String uid = userCredential.user!.uid;

      UserModel userModel = UserModel(
        userId: uid,
        password: hashPassword(password),
        companyId: companyId,
        companyName: companyName,
        branchId: branchId,
        empId: normalizedRole == "Manager"
            ? "ADMIN-$companyId"
            : "EMP-${uid.substring(0, 5)}",
        name: name.trim(),
        email: normalizedEmail,
        role: normalizedRole,
        skills: skills,
        maxCapacityHoursPerWeek: maxCapacity,
        createdAt: DateTime.now(),
        currentWorkloadPercentage: 0.0,
      );

      await fireStore.collection("users").doc(uid).set(userModel.toJson());
      await tempApp.delete();
      return uid;
    } catch (e) {
      debugPrint("Error creating account in background: $e");
      await tempApp.delete();
      rethrow;
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
    required String companyId,
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
            password: hashPassword(password),
            companyId: companyId,
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
