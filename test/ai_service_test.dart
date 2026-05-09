import 'package:aiq/models/task_model.dart';
import 'package:aiq/services/ai_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiService taskFollowUp', () {
    test('asks admins to review submitted work', () {
      final task = _task(status: 'Submitted');

      final followUp = AiService().taskFollowUp(task);

      expect(followUp, contains('Review the submission'));
      expect(followUp, contains('approve or request rework'));
    });

    test('flags overdue incomplete work', () {
      final task = _task(
        status: 'In Progress',
        endTime: DateTime.now().subtract(const Duration(hours: 2)),
      );

      final followUp = AiService().taskFollowUp(task);

      expect(followUp, contains('overdue'));
      expect(followUp, contains('blocker update'));
    });

    test('nudges pending tasks toward confirmation', () {
      final task = _task(status: 'Pending');

      final followUp = AiService().taskFollowUp(task);

      expect(followUp, contains('confirm start time'));
      expect(followUp, contains('missing requirements'));
    });
  });
}

TaskModel _task({required String status, DateTime? endTime}) {
  final start = DateTime.now().add(const Duration(hours: 1));
  return TaskModel(
    taskId: 'TASK-test',
    companyId: 'COMP-test',
    branchId: 'BR-test',
    title: 'Prepare release report',
    description: 'Summarize release status and blockers.',
    assignedTo: 'EMP-test',
    assignedBy: 'ADMIN-test',
    startTime: start,
    endTime: endTime ?? start.add(const Duration(hours: 2)),
    estimatedDurationMinutes: 120,
    basePriority: 'High',
    status: status,
    createdAt: DateTime.now(),
  );
}
