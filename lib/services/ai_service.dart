import 'dart:convert';

import 'package:aiq/models/user_model.dart';
import 'package:http/http.dart' as http;

class AiService {
  final String url = "https://aiq-mhbh.onrender.com";

  Future<List<Map<String,dynamic>>> getSmartSuggestions({
    required List<String> requiredSkills ,
    required String priority,
    required DateTime deadline,
    required List<UserModel> employees
})async{
    try{
      final body = jsonEncode({
        "task": {
          "requiredSkills": requiredSkills,
          "basePriority": priority,
          "endTime": deadline.toUtc().toIso8601String(),
          "isBlocking": false
        },
        "employees": employees.map((e) {
          return {
            "userId": e.userId,
            "name": e.name,
            "skills": e.skills,
            "currentWorkloadPercentage": e.currentWorkloadPercentage,
            "isAvailable": true
          };
        }).toList()
      });

      print("AI Request Body: $body");

      final response = await http.post(
          Uri.parse("$url/suggest-best-employee"),
          headers: {"Content-Type": "application/json"},
          body: body
      );

      print("AI Response Status: ${response.statusCode}");
      print("AI Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print("AI Server Error: ${response.statusCode} ${response.body}");
      }
    }catch(e){
      print("AI Service Error : $e");
    }
    return [];
  }
}