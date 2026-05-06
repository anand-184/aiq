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
      final response = await http.post(
        Uri.parse("$url/suggest-best-employee"),
        headers:{"Content-Type":"application/json"},
        body: jsonEncode({
          "task":{
            "requiredSkills":requiredSkills,
            "basePriority":priority,
            "endTime":deadline.toUtc().toIso8601String(),
            "isBlocking":false
          },
          "employees":employees.map((e)=>{
            "userId":e.userId,
            "name":e.name,
            "skills":e.skills,
            "currentWorkloadPercentage":e.currentWorkloadPercentage,
            "isAvailable":true
          }).toList()
        })

      );

      if(response.statusCode ==200){
        return List<Map<String,dynamic>>.from(jsonDecode(response.body));
      }
    }catch(e){
      print("AI Service Error : $e");
    }
    return [];
  }
}