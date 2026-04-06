import 'package:aiq/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore= FirebaseFirestore.instance;

  Future<void> registerUser({required String email,
    required String password,
    required String companyName,
    required String branchId,
    required String empId,
    required String name,
    required String phone,
    required String role,
    List<String> skills= const [],}) async {
    try{
      UserCredential userCredential = await firebaseAuth.
      createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if(user!=null){
        UserModel userModel = UserModel(
            userId: user.uid,
            companyName: companyName,
            branchId: branchId,
            empId: empId,
            name: name,
            email: email,
            role: role,
            maxCapacityHoursPerWeek: 0, createdAt:DateTime.now(),
            skills: skills,
            googleCalendarTokens:{},
            currentWorkloadPercentage:0.0
        );
        await fireStore.collection("users").doc(user.uid).set(userModel.toJson());
      }
    }on FirebaseAuthException catch(e){
      if(e.code == "weak-password"){
        print("The password provided is too weak");
      }else if(e.code == "email-already-in-use"){
        print("The account already exists for that email");
      }
      throw e;
      }catch(e){
      print(e);
      throw Exception("Failed to register user : $e");
    }
    }

  }