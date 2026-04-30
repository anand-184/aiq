import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AIService {
  // Replace with your production URL once deployed (Render/Railway)
  final String baseUrl = "http://localhost:8000";

  Future<List<Map<String, dynamic>>> getSmartRecommendations({
    required String companyId,
    required List<String> requiredSkills,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/recommend"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "companyId": companyId,
          "requiredSkills": requiredSkills,
          "startTime": startTime.toIso8601String(),
          "endTime": endTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("AI Recommendation Failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("AI Service Error: $e");
    }
  }
}
