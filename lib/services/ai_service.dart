import 'dart:convert';

import 'package:aiq/models/performance_metric.dart';
import 'package:aiq/models/task_model.dart';
import 'package:aiq/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiService {
  final String url = "https://aiq-mhbh.onrender.com";

  Future<List<Map<String, dynamic>>> getSmartSuggestions({
    required List<String> requiredSkills,
    required String priority,
    required DateTime deadline,
    required List<UserModel> employees,
  }) async {
    try {
      final body = jsonEncode({
        "task": {
          "requiredSkills": requiredSkills,
          "basePriority": priority,
          "endTime": deadline.toUtc().toIso8601String(),
          "isBlocking": false,
        },
        "employees": employees.map((e) {
          return {
            "userId": e.userId,
            "name": e.name,
            "skills": e.skills,
            "currentWorkloadPercentage": e.currentWorkloadPercentage,
            "isAvailable": true,
          };
        }).toList(),
      });

      debugPrint("AI Request Body: $body");

      final response = await http.post(
        Uri.parse("$url/suggest-best-employee"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("AI Response Status: ${response.statusCode}");
      debugPrint("AI Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        debugPrint("AI Server Error: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("AI Service Error : $e");
    }
    return _localSmartSuggestions(
      requiredSkills: requiredSkills,
      employees: employees,
    );
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
      debugPrint("Analytics RAG Error: $e");
    }

    return _localAnalyticsAnswer(question, documents);
  }

  Future<List<Map<String, dynamic>>> getPerformanceInsights({
    required List<UserModel> employees,
    required List<TaskModel> tasks,
    required List<PerformanceMetric> metrics,
  }) async {
    final signals = employees.map((employee) {
      final userTasks = tasks
          .where((task) => task.assignedTo == employee.userId)
          .toList();
      final userMetrics = metrics
          .where((metric) => metric.userId == employee.userId)
          .toList();
      final completed = userTasks
          .where((task) => task.status == "Completed")
          .length;
      final inProgress = userTasks
          .where((task) => task.status == "In Progress")
          .length;
      final pending = userTasks
          .where((task) => task.status == "Pending")
          .length;
      final avgFocus = userMetrics.isEmpty
          ? 0
          : userMetrics
                    .map((metric) => metric.focusMinutes)
                    .reduce((a, b) => a + b) /
                userMetrics.length;
      final appMinutes = userMetrics.fold<int>(
        0,
        (total, metric) => total + metric.appScreenMinutes,
      );
      final typingScore = userMetrics.isEmpty
          ? 0
          : userMetrics
                    .map((metric) => metric.typingActivityScore)
                    .reduce((a, b) => a + b) /
                userMetrics.length;
      final keystrokesPerHour = userMetrics.isEmpty
          ? 0
          : userMetrics
                    .map((metric) => metric.keystrokesPerHour)
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
        "keystrokesPerHour": keystrokesPerHour,
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
      debugPrint("Performance AI Error: $e");
    }

    return signals.map((signal) {
      final total =
          (signal["completedTasks"] as int) +
          (signal["inProgressTasks"] as int) +
          (signal["pendingTasks"] as int);
      final completionRate = total == 0
          ? 0.0
          : ((signal["completedTasks"] as int) / total) * 100;
      final focusScore = ((signal["averageFocusMinutes"] as num) / 120 * 100)
          .clamp(0, 100);
      final activityScore = ((signal["typingActivityScore"] as num)).clamp(
        0,
        100,
      );
      final keystrokeScore = ((signal["keystrokesPerHour"] as num) / 1800 * 100)
          .clamp(0, 100);
      final workloadScore = (100 - (signal["workloadPercentage"] as num)).clamp(
        0,
        100,
      );
      final efficiency =
          (completionRate * 0.55 +
                  focusScore * 0.25 +
                  activityScore * 0.07 +
                  keystrokeScore * 0.03 +
                  workloadScore * 0.10)
              .clamp(0, 100);
      final pending = signal["pendingTasks"] as int;
      final risk = (signal["workloadPercentage"] as num) > 85 && pending > 0
          ? "Burnout risk"
          : efficiency < 45
          ? "Needs support"
          : "Healthy";
      return {
        "userId": signal["userId"],
        "employeeName": signal["employeeName"],
        "efficiencyScore": efficiency,
        "completionRate": completionRate,
        "keystrokesPerHour": signal["keystrokesPerHour"],
        "risk": risk,
        "recommendation": risk == "Burnout risk"
            ? "Reduce new assignments and move urgent work to a lower-load teammate."
            : risk == "Needs support"
            ? "Review blockers, split pending work, and schedule a manager follow-up."
            : "Good candidate for suitable tasks.",
      };
    }).toList();
  }

  List<Map<String, dynamic>> _localSmartSuggestions({
    required List<String> requiredSkills,
    required List<UserModel> employees,
  }) {
    final required = requiredSkills
        .expand(_skillTokens)
        .where((skill) => skill.length > 1)
        .toSet();
    final ranked = employees.map((employee) {
      final owned = employee.skills.expand(_skillTokens).toSet();
      final exactMatches = required.where(owned.contains).length;
      final fuzzyMatches = required.where((skill) {
        return owned.any(
          (ownedSkill) =>
              ownedSkill.contains(skill) || skill.contains(ownedSkill),
        );
      }).length;
      final skillScore = required.isEmpty
          ? 100.0
          : ((exactMatches * 1.0 + (fuzzyMatches - exactMatches) * 0.45) /
                    required.length *
                    100)
                .clamp(0, 100)
                .toDouble();
      final workloadScore = (100 - employee.currentWorkloadPercentage)
          .clamp(0, 100)
          .toDouble();
      final score = skillScore * 0.75 + workloadScore * 0.25;
      return {
        "userId": employee.userId,
        "name": employee.name,
        "score": score,
        "matchLevel": (score / 10).clamp(0, 10),
        "reason":
            "${skillScore.toStringAsFixed(0)}% skill match | ${employee.currentWorkloadPercentage.toStringAsFixed(0)}% workload",
      };
    }).toList();
    ranked.sort((a, b) => (b["score"] as num).compareTo(a["score"] as num));
    return ranked;
  }

  Set<String> _skillTokens(String skill) {
    final normalized = skill.toLowerCase().trim();
    final tokens = normalized
        .split(RegExp(r"[^a-z0-9+#.]+"))
        .where((part) => part.isNotEmpty)
        .toSet();
    if (normalized.contains("django")) tokens.addAll({"django", "python"});
    if (normalized.contains("flutter")) tokens.addAll({"flutter", "dart"});
    if (normalized.contains("firebase")) {
      tokens.addAll({"firebase", "firestore"});
    }
    if (normalized.contains("sql")) tokens.add("sql");
    return tokens;
  }

  String taskFollowUp(TaskModel task) {
    final overdue =
        task.endTime.isBefore(DateTime.now()) && task.status != "Completed";
    if (task.status == "Submitted") {
      return "Review the submission note and proof link, then approve or request rework with specific feedback.";
    }
    if (overdue) {
      return "This task is overdue. Ask for a blocker update and consider reassigning part of the scope.";
    }
    if (task.status == "Pending") {
      return "Ask the assignee to confirm start time, expected delivery, and any missing requirements.";
    }
    if (task.status == "In Progress") {
      return "Request a short progress update and check whether the deadline still looks realistic.";
    }
    return "Capture final learnings and keep the assignee available for similar future work.";
  }

  String _localAnalyticsAnswer(
    String question,
    List<Map<String, dynamic>> documents,
  ) {
    if (documents.isEmpty) {
      return "I do not have analytics context yet.";
    }
    final skillAnswer = _skillAnalyticsAnswer(question, documents);
    if (skillAnswer != null) return skillAnswer;

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

    final snippets = ranked
        .take(3)
        .map((doc) {
          return "- ${doc['title']}: ${doc['content']}";
        })
        .join("\n");

    return "Here are the strongest matching analytics signals:\n$snippets";
  }

  String? _skillAnalyticsAnswer(
    String question,
    List<Map<String, dynamic>> documents,
  ) {
    final lowerQuestion = question.toLowerCase();
    final skillMatch = RegExp(
      r"(?:skill|skills|with|knows|know)\s+([a-z0-9+#.]+)",
    ).allMatches(lowerQuestion).toList();
    final fallback = RegExp(
      r"(django|flutter|firebase|python|sql|ml|ai|dart|java|react|node)",
    ).firstMatch(lowerQuestion);
    final skill = skillMatch.isNotEmpty
        ? skillMatch.last.group(1)
        : fallback?.group(1);
    if (skill == null || skill.isEmpty) return null;

    final wanted = _skillTokens(skill);
    final matches = <String>[];
    for (final doc in documents) {
      if (doc["metadata"] is! Map ||
          (doc["metadata"] as Map)["type"] != "employee") {
        continue;
      }
      final content = "${doc['title']} ${doc['content']}".toLowerCase();
      final tokens = _skillTokens(content);
      if (wanted.any(tokens.contains)) {
        matches.add(doc["title"].toString().replaceFirst("Employee ", ""));
      }
    }

    if (matches.isEmpty) {
      return "I could not find any employees with $skill in the current analytics data.";
    }
    return "Employees matching $skill: ${matches.join(', ')}.";
  }
}
