import 'package:aiq/models/task_model.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarService {
  Uri googleCalendarUri(TaskModel task) {
    final dates =
        "${_googleDate(task.startTime.toUtc())}/${_googleDate(task.endTime.toUtc())}";
    return Uri.https("calendar.google.com", "/calendar/render", {
      "action": "TEMPLATE",
      "text": task.title,
      "details": [
        task.description,
        if (task.requiredSkills.isNotEmpty)
          "Required skills: ${task.requiredSkills.join(', ')}",
        "Priority: ${task.basePriority.isEmpty ? 'Normal' : task.basePriority}",
      ].join("\n\n"),
      "dates": dates,
    });
  }

  Future<bool> openGoogleCalendar(TaskModel task) async {
    final uri = googleCalendarUri(task);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    await Clipboard.setData(ClipboardData(text: uri.toString()));
    return false;
  }

  String _googleDate(DateTime dateTime) {
    String two(int value) => value.toString().padLeft(2, "0");
    return "${dateTime.year}${two(dateTime.month)}${two(dateTime.day)}T"
        "${two(dateTime.hour)}${two(dateTime.minute)}${two(dateTime.second)}Z";
  }
}
