import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../models/task_model.dart';

class GoogleCalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      CalendarApi.calendarEventsScope,
    ],
  );

  Future<CalendarApi?> _getCalendarApi() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final httpClient = await googleUser.authenticatedClient();
    if (httpClient == null) return null;

    return CalendarApi(httpClient);
  }

  Future<String?> addTaskToCalendar(TaskModel task) async {
    try {
      final calendarApi = await _getCalendarApi();
      if (calendarApi == null) return null;

      final event = Event()
        ..summary = task.title
        ..description = task.description
        ..start = (EventDateTime()
          ..dateTime = task.startTime.toUtc()
          ..timeZone = "UTC")
        ..end = (EventDateTime()
          ..dateTime = task.endTime.toUtc()
          ..timeZone = "UTC");

      final createdEvent = await calendarApi.events.insert(event, "primary");
      return createdEvent.id;
    } catch (e) {
      print("Google Calendar Error: $e");
      return null;
    }
  }
}

// Note: You need to add 'extension_google_sign_in_as_googleapis_auth' to pubspec.yaml
