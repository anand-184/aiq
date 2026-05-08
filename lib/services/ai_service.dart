import 'dart:convert';

import 'package:aiq/models/performance_metric.dart';
import 'package:aiq/models/task_model.dart';
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

  Future<String> askAnalytics({
    required String question,
    required String role,
    required List<Map<String, dynamic>> documents,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$url/analytics-rag"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": question,
          "role": role,
          "documents": documents,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded["answer"] as String? ?? "No answer returned.";
      }
    } catch (e) {
      print("Analytics RAG Error: $e");
    }

    return _localAnalyticsAnswer(question, documents);
  }

  Future<List<Map<String, dynamic>>> getPerformanceInsights({
    required List<UserModel> employees,
    required List<TaskModel> tasks,
    required List<PerformanceMetric> metrics,
  }) async {
    final signals = employees.map((employee) {
      final userTasks =
          tasks.where((task) => task.assignedTo == employee.userId).toList();
      final userMetrics =
          metrics.where((metric) => metric.userId == employee.userId).toList();
      final completed =
          userTasks.where((task) => task.status == "Completed").length;
      final inProgress =
          userTasks.where((task) => task.status == "In Progress").length;
      final pending = userTasks.where((task) => task.status == "Pending").length;
      final avgFocus = userMetrics.isEmpty
          ? 0
          : userMetrics
                  .map((metric) => metric.focusMinutes)
                  .reduce((a, b) => a + b) /
              userMetrics.length;
      final appMinutes = userMetrics.fold<int>(
          0, (total, metric) => total + metric.appScreenMinutes);
      final typingScore = userMetrics.isEmpty
          ? 0
          : userMetrics
                  .map((metric) => metric.typingActivityScore)
                  .reduce((a, b) => a + b) /
              userMetrics.length;

      return {
        "userId": employee.userId,
        "employeeName": employee.name,
        "completedTasks": completed,
        "inProgressTasks": inProgress,
        "pendingTasks": pending,
        "averageFocusMinutes": avgFocus,
        "appScreenMinutes": appMinutes,
        "typingActivityScore": typingScore,
        "workloadPercentage": employee.currentWorkloadPercentage,
      };
    }).toList();

    try {
      final response = await http.post(
        Uri.parse("$url/performance-insights"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signals),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
    } catch (e) {
      print("Performance AI Error: $e");
    }

    return signals.map((signal) {
      final total = (signal["completedTasks"] as int) +
          (signal["inProgressTasks"] as int) +
          (signal["pendingTasks"] as int);
      final completionRate =
          total == 0 ? 0.0 : ((signal["completedTasks"] as int) / total) * 100;
      final efficiency = (completionRate * 0.7 +
              (100 - (signal["workloadPercentage"] as double)) * 0.3)
          .clamp(0, 100);
      return {
        "userId": signal["userId"],
        "employeeName": signal["employeeName"],
        "efficiencyScore": efficiency,
        "completionRate": completionRate,
        "risk": efficiency < 45 ? "Needs support" : "Healthy",
        "recommendation": efficiency < 45
            ? "Review workload and provide support."
            : "Good candidate for suitable tasks.",
      };
    }).toList();
  }

  String _localAnalyticsAnswer(
    String question,
    List<Map<String, dynamic>> documents,
  ) {
    if (documents.isEmpty) {
      return "I do not have analytics context yet.";
    }
    final terms = question
        .toLowerCase()
        .split(RegExp(r"\W+"))
        .where((term) => term.length > 2)
        .toSet();
    final ranked = [...documents];
    ranked.sort((a, b) {
      int score(Map<String, dynamic> doc) {
        final text = "${doc['title']} ${doc['content']}".toLowerCase();
        return terms.where(text.contains).length;
      }

      return score(b).compareTo(score(a));
    });

    final snippets = ranked.take(3).map((doc) {
      return "- ${doc['title']}: ${doc['content']}";
    }).join("\n");

    return "Here are the strongest matching analytics signals:\n$snippets";
  }
}
