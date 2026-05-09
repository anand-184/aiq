import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../models/feedback_model.dart';
import '../../services/ai_service.dart';
import '../../services/calendar_service.dart';
import '../../viewmodels/employee_viewmodel.dart';
import '../login_screen.dart';

class EmpHomescreen extends StatefulWidget {
  const EmpHomescreen({super.key});

  @override
  State<EmpHomescreen> createState() => _EmpHomescreenState();
}

class _EmpHomescreenState extends State<EmpHomescreen> {
  int _selectedIndex = 0;

  final List<String> _titles = const [
    "Employee Overview",
    "My Tasks",
    "Schedule",
    "Team Slots",
    "Feedback",
    "Profile",
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EmployeeViewModel>(context);

    return StreamBuilder<UserModel>(
      stream: viewModel.profileStream,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (profileSnapshot.hasError || !profileSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text("Employee Portal")),
            body: const Center(child: Text("Error loading profile")),
          );
        }

        final user = profileSnapshot.data!;

        return StreamBuilder<List<TaskModel>>(
          stream: viewModel.myTasksStream,
          builder: (context, taskSnapshot) {
            final tasks = taskSnapshot.data ?? [];
            final isLoadingTasks =
                taskSnapshot.connectionState == ConnectionState.waiting;

            return Scaffold(
              appBar: AppBar(
                title: Text(_titles[_selectedIndex]),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              drawer: _EmployeeSidePanel(
                user: user,
                selectedIndex: _selectedIndex,
                onSelect: (index) {
                  setState(() => _selectedIndex = index);
                  Navigator.pop(context);
                },
                onLogout: () => _logout(context, viewModel),
              ),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.02, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_selectedIndex),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _EmployeeOverviewTab(
                        user: user,
                        tasks: tasks,
                        isLoading: isLoadingTasks,
                        onOpenTasks: () => setState(() => _selectedIndex = 1),
                        onStatusChanged: viewModel.updateTaskStatus,
                      ),
                      _EmployeeTasksTab(
                        tasks: tasks,
                        isLoading: isLoadingTasks,
                        onStatusChanged: viewModel.updateTaskStatus,
                      ),
                      _EmployeeScheduleTab(
                        tasks: tasks,
                        isLoading: isLoadingTasks,
                        onStatusChanged: viewModel.updateTaskStatus,
                      ),
                      _EmployeeTeamSlotsTab(user: user, viewModel: viewModel),
                      _EmployeeFeedbackTab(user: user, viewModel: viewModel),
                      _EmployeeProfileTab(
                        user: user,
                        tasks: tasks,
                        onSave: viewModel.updateProfile,
                        onRecordPerformance:
                            viewModel.recordPerformanceSnapshot,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, EmployeeViewModel vm) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Do you want to end this employee session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;
    await vm.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class _EmployeeSidePanel extends StatelessWidget {
  const _EmployeeSidePanel({
    required this.user,
    required this.selectedIndex,
    required this.onSelect,
    required this.onLogout,
  });

  final UserModel user;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = _initialsFor(user.name);

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
            color: colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${user.role} - ${user.companyName}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withOpacity(0.72),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _panelTile(context, Icons.dashboard_outlined, "Overview", 0),
                _panelTile(context, Icons.assignment_outlined, "My Tasks", 1),
                _panelTile(
                  context,
                  Icons.calendar_month_outlined,
                  "Schedule",
                  2,
                ),
                _panelTile(context, Icons.groups_outlined, "Team Slots", 3),
                _panelTile(context, Icons.feedback_outlined, "Feedback", 4),
                _panelTile(context, Icons.person_outline, "Profile", 5),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: onLogout,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _panelTile(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    final selected = selectedIndex == index;
    return ListTile(
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onSelect(index),
    );
  }
}

class _EmployeeOverviewTab extends StatelessWidget {
  const _EmployeeOverviewTab({
    required this.user,
    required this.tasks,
    required this.isLoading,
    required this.onOpenTasks,
    required this.onStatusChanged,
  });

  final UserModel user;
  final List<TaskModel> tasks;
  final bool isLoading;
  final VoidCallback onOpenTasks;
  final Future<void> Function(TaskModel task, String status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pending = tasks.where((t) => t.status == "Pending").length;
    final active = tasks.where((t) => t.status == "In Progress").length;
    final completed = tasks.where((t) => t.status == "Completed").length;
    final workload = _calculateWorkloadPercentage(user, tasks);
    final nextTasks = [...tasks]
      ..sort((a, b) => a.endTime.compareTo(b.endTime));

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _WelcomeBand(user: user, workloadPercentage: workload),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricCard(
                label: "Pending",
                value: "$pending",
                icon: Icons.hourglass_empty,
                color: Colors.orange,
              ),
              const SizedBox(width: 10),
              _MetricCard(
                label: "Active",
                value: "$active",
                icon: Icons.play_circle_outline,
                color: Colors.blue,
              ),
              const SizedBox(width: 10),
              _MetricCard(
                label: "Done",
                value: "$completed",
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _WorkloadCard(user: user, workloadPercentage: workload),
          const SizedBox(height: 20),
          _SectionHeader(
            title: "Priority Queue",
            actionLabel: "View all",
            onAction: onOpenTasks,
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (nextTasks.isEmpty)
            const _EmptyState(
              icon: Icons.task_alt,
              title: "No assigned tasks",
              message: "New tasks from your admin will appear here.",
            )
          else
            ...nextTasks
                .take(3)
                .map(
                  (task) => _TaskCard(
                    task: task,
                    compact: true,
                    onStatusChanged: onStatusChanged,
                  ),
                )
                .toList(),
          const SizedBox(height: 8),
          Text(
            "Skills: ${user.skills.isEmpty ? 'Not added yet' : user.skills.join(', ')}",
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.68)),
          ),
        ],
      ),
    );
  }
}

class _EmployeeTasksTab extends StatefulWidget {
  const _EmployeeTasksTab({
    required this.tasks,
    required this.isLoading,
    required this.onStatusChanged,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final Future<void> Function(TaskModel task, String status) onStatusChanged;

  @override
  State<_EmployeeTasksTab> createState() => _EmployeeTasksTabState();
}

class _EmployeeTasksTabState extends State<_EmployeeTasksTab> {
  String _statusFilter = "All";

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _statusFilter == "All"
        ? widget.tasks
        : widget.tasks.where((task) => task.status == _statusFilter).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: ["All", "Pending", "In Progress", "Completed"]
                .map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: _statusFilter == status,
                      onSelected: (_) => setState(() => _statusFilter = status),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredTasks.isEmpty
              ? _EmptyState(
                  icon: Icons.assignment_outlined,
                  title: "Nothing in $_statusFilter",
                  message: "Try another status filter.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) => _TaskCard(
                    task: filteredTasks[index],
                    onStatusChanged: widget.onStatusChanged,
                  ),
                ),
        ),
      ],
    );
  }
}

class _EmployeeScheduleTab extends StatelessWidget {
  const _EmployeeScheduleTab({
    required this.tasks,
    required this.isLoading,
    required this.onStatusChanged,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final Future<void> Function(TaskModel task, String status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final scheduledTasks = [...tasks]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scheduledTasks.isEmpty) {
      return const _EmptyState(
        icon: Icons.calendar_today_outlined,
        title: "Schedule is clear",
        message: "Assigned tasks will be grouped by day here.",
      );
    }

    DateTime? activeDay;
    final items = <Widget>[];

    for (final task in scheduledTasks) {
      final taskDay = DateTime(
        task.startTime.year,
        task.startTime.month,
        task.startTime.day,
      );
      if (activeDay != taskDay) {
        activeDay = taskDay;
        items.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Text(
              _formatDateLabel(task.startTime),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }

      items.add(
        _TimelineTaskTile(task: task, onStatusChanged: onStatusChanged),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: items,
    );
  }
}

class _EmployeeTeamSlotsTab extends StatefulWidget {
  const _EmployeeTeamSlotsTab({required this.user, required this.viewModel});

  final UserModel user;
  final EmployeeViewModel viewModel;

  @override
  State<_EmployeeTeamSlotsTab> createState() => _EmployeeTeamSlotsTabState();
}

class _EmployeeTeamSlotsTabState extends State<_EmployeeTeamSlotsTab> {
  String? _selectedMemberId;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: widget.viewModel.teamMembersStream(widget.user.companyId),
      builder: (context, memberSnapshot) {
        if (memberSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members =
            (memberSnapshot.data ?? [])
                .where((member) => member.role != "SuperAdmin")
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));

        if (members.isEmpty) {
          return const _EmptyState(
            icon: Icons.groups_outlined,
            title: "No team members found",
            message: "Team members created by your admin will appear here.",
          );
        }

        final selectedMember = members.firstWhere(
          (member) => member.userId == _selectedMemberId,
          orElse: () => members.first,
        );
        _selectedMemberId = selectedMember.userId;

        return StreamBuilder<List<TaskModel>>(
          stream: widget.viewModel.teamTasksStream(widget.user.companyId),
          builder: (context, taskSnapshot) {
            final tasks = taskSnapshot.data ?? [];
            final memberTasks = _tasksForMemberOnDate(
              tasks,
              selectedMember.userId,
              _selectedDate,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _SectionHeader(
                  title: "Team Availability",
                  actionLabel: "Assign",
                  onAction: () => _showAssignTaskDialog(
                    context,
                    members,
                    selectedMember: selectedMember,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedMember.userId,
                  items: members
                      .map(
                        (member) => DropdownMenuItem(
                          value: member.userId,
                          child: Text(member.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedMemberId = value);
                  },
                  decoration: const InputDecoration(
                    labelText: "Team member",
                    prefixIcon: Icon(Icons.person_search_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      tooltip: "Previous day",
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(
                            const Duration(days: 1),
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _formatDateLabel(_selectedDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: "Next day",
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(
                            const Duration(days: 1),
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (taskSnapshot.connectionState == ConnectionState.waiting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  ...List.generate(10, (index) {
                    final hour = 9 + index;
                    final slotStart = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      hour,
                    );
                    final slotEnd = slotStart.add(const Duration(hours: 1));
                    final slotTasks = memberTasks
                        .where((task) => _overlaps(task, slotStart, slotEnd))
                        .toList();

                    return _TeamSlotTile(
                      startTime: slotStart,
                      endTime: slotEnd,
                      tasks: slotTasks,
                      onTap: slotTasks.isEmpty
                          ? () => _showAssignTaskDialog(
                              context,
                              members,
                              selectedMember: selectedMember,
                              startTime: slotStart,
                              endTime: slotEnd,
                            )
                          : () => _showSlotTasks(context, slotTasks),
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }

  List<TaskModel> _tasksForMemberOnDate(
    List<TaskModel> tasks,
    String userId,
    DateTime date,
  ) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return tasks
        .where(
          (task) =>
              task.assignedTo == userId &&
              task.status != "Completed" &&
              task.startTime.isBefore(dayEnd) &&
              task.endTime.isAfter(dayStart),
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  bool _overlaps(TaskModel task, DateTime startTime, DateTime endTime) {
    return task.startTime.isBefore(endTime) && task.endTime.isAfter(startTime);
  }

  void _showSlotTasks(BuildContext context, List<TaskModel> tasks) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const Text(
            "Busy Slot",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...tasks.map(
            (task) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.circle, color: _statusColor(task.status)),
              title: Text(task.title),
              subtitle: Text(
                "${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}",
              ),
              trailing: _PriorityPill(priority: task.basePriority),
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignTaskDialog(
    BuildContext context,
    List<UserModel> members, {
    UserModel? selectedMember,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final skillsController = TextEditingController();
    String priority = "Medium";
    String assignedTo = selectedMember?.userId ?? members.first.userId;
    DateTime selectedStart =
        startTime ?? DateTime.now().add(const Duration(hours: 1));
    DateTime selectedEnd =
        endTime ?? selectedStart.add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Assign Task"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Task Title"),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Enter a task title";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                    minLines: 1,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: skillsController,
                    decoration: const InputDecoration(
                      labelText: "Required skills",
                      hintText: "Flutter, Firebase",
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        "Assignee",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text("AI Suggest"),
                        onPressed: () async {
                          final suggestions = await AiService()
                              .getSmartSuggestions(
                                requiredSkills: skillsController.text
                                    .split(",")
                                    .map((skill) => skill.trim())
                                    .where((skill) => skill.isNotEmpty)
                                    .toList(),
                                priority: priority,
                                deadline: selectedEnd,
                                employees: members,
                              );
                          if (suggestions.isNotEmpty && context.mounted) {
                            _showEmployeeAISuggestionsDialog(
                              context,
                              suggestions,
                              (selectedId) {
                                setDialogState(() => assignedTo = selectedId);
                              },
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("No suggestions found"),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  DropdownButtonFormField<String>(
                    value: assignedTo,
                    items: members
                        .map(
                          (member) => DropdownMenuItem(
                            value: member.userId,
                            child: Text(member.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => assignedTo = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: "Assign To"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: priority,
                    items: ["Low", "Medium", "High", "Critical"]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => priority = value);
                      }
                    },
                    decoration: const InputDecoration(labelText: "Priority"),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Start Time"),
                    subtitle: Text(
                      "${_formatDateLabel(selectedStart)} ${_formatTime(selectedStart)}",
                    ),
                    trailing: const Icon(Icons.event_outlined),
                    onTap: () async {
                      final picked = await _pickDateTime(
                        context,
                        selectedStart,
                      );
                      if (picked == null) return;
                      setDialogState(() {
                        selectedStart = picked;
                        if (!selectedEnd.isAfter(selectedStart)) {
                          selectedEnd = selectedStart.add(
                            const Duration(hours: 1),
                          );
                        }
                      });
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("End Time"),
                    subtitle: Text(
                      "${_formatDateLabel(selectedEnd)} ${_formatTime(selectedEnd)}",
                    ),
                    trailing: const Icon(Icons.event_available_outlined),
                    onTap: () async {
                      final picked = await _pickDateTime(context, selectedEnd);
                      if (picked == null) return;
                      setDialogState(() => selectedEnd = picked);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final assignee = members.firstWhere(
                  (member) => member.userId == assignedTo,
                  orElse: () => members.first,
                );
                final result = await widget.viewModel.assignTask(
                  companyId: widget.user.companyId,
                  branchId: assignee.branchId.isNotEmpty
                      ? assignee.branchId
                      : widget.user.branchId,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? "Assigned by ${widget.user.name}"
                      : descriptionController.text.trim(),
                  requiredSkills: skillsController.text
                      .split(",")
                      .map((skill) => skill.trim())
                      .where((skill) => skill.isNotEmpty)
                      .toList(),
                  assignedTo: assignedTo,
                  startTime: selectedStart,
                  endTime: selectedEnd,
                  basePriority: priority,
                );

                if (!context.mounted) return;
                if (result == "success") {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Task assigned successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result)));
                }
              },
              child: const Text("Assign"),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(
    BuildContext context,
    DateTime initialDateTime,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

class _TeamSlotTile extends StatelessWidget {
  const _TeamSlotTile({
    required this.startTime,
    required this.endTime,
    required this.tasks,
    required this.onTap,
  });

  final DateTime startTime;
  final DateTime endTime;
  final List<TaskModel> tasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isBusy = tasks.isNotEmpty;
    final color = isBusy ? Colors.blue : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(
                width: 86,
                child: Text(
                  "${_formatTime(startTime)}\n${_formatTime(endTime)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: 10,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBusy ? "Busy" : "Available",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBusy
                          ? tasks.map((task) => task.title).join(", ")
                          : "Tap to assign a task in this slot.",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.64),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(isBusy ? Icons.visibility_outlined : Icons.add_task),
            ],
          ),
        ),
      ),
    );
  }
}

void _showEmployeeAISuggestionsDialog(
  BuildContext context,
  List<Map<String, dynamic>> suggestions,
  ValueChanged<String> onSelect,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.blue),
          SizedBox(width: 10),
          Text("AI Suggestions"),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            final score = suggestion["matchLevel"] ?? suggestion["score"] ?? 0;
            return Card(
              child: ListTile(
                title: Text(suggestion["name"] ?? "Unknown"),
                subtitle: Text(suggestion["reason"] ?? ""),
                trailing: Text(
                  "$score",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  onSelect(suggestion["userId"] as String);
                  Navigator.pop(context);
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

class _EmployeeFeedbackTab extends StatelessWidget {
  const _EmployeeFeedbackTab({required this.user, required this.viewModel});

  final UserModel user;
  final EmployeeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _SectionHeader(
            title: "Feedback",
            actionLabel: "New",
            onAction: () => _showFeedbackDialog(context),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<FeedbackModel>>(
            stream: viewModel.feedbackStream(user.companyId),
            builder: (context, snapshot) {
              final feedback = (snapshot.data ?? [])
                  .where((item) => item.userId == user.userId)
                  .toList();
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (feedback.isEmpty) {
                return const _EmptyState(
                  icon: Icons.feedback_outlined,
                  title: "No feedback yet",
                  message: "Share product, workload, or task process feedback.",
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: feedback.length,
                itemBuilder: (context, index) {
                  final item = feedback[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.feedback_outlined),
                      title: Text(item.category),
                      subtitle: Text(item.message),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("${item.rating}/5"),
                          Text(
                            item.status,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final messageController = TextEditingController();
    String category = "Product";
    int rating = 4;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Send Feedback"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                items: ["Product", "Workload", "Task Assignment", "Support"]
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => category = value);
                },
                decoration: const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: rating,
                items: [1, 2, 3, 4, 5]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text("$item / 5"),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setDialogState(() => rating = value);
                },
                decoration: const InputDecoration(labelText: "Rating"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: "Message"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (messageController.text.trim().isEmpty) return;
                await viewModel.submitFeedback(
                  user: user,
                  category: category,
                  message: messageController.text.trim(),
                  rating: rating,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Send"),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeeProfileTab extends StatelessWidget {
  const _EmployeeProfileTab({
    required this.user,
    required this.tasks,
    required this.onSave,
    required this.onRecordPerformance,
  });

  final UserModel user;
  final List<TaskModel> tasks;
  final Future<void> Function(UserModel user) onSave;
  final Future<void> Function({
    required UserModel user,
    required int appScreenMinutes,
    required int focusMinutes,
    required int typedCharacters,
    required int correctionCount,
    required int taskSwitches,
  })
  onRecordPerformance;

  @override
  Widget build(BuildContext context) {
    final completed = tasks.where((task) => task.status == "Completed").length;
    final completionRate = tasks.isEmpty
        ? 0.0
        : (completed / tasks.length) * 100;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _ProfileHeader(user: user),
        const SizedBox(height: 16),
        Row(
          children: [
            _MetricCard(
              label: "Completion",
              value: "${completionRate.toStringAsFixed(0)}%",
              icon: Icons.insights,
              color: Colors.green,
            ),
            const SizedBox(width: 10),
            _MetricCard(
              label: "Capacity",
              value: "${user.maxCapacityHoursPerWeek.toStringAsFixed(0)}h",
              icon: Icons.speed,
              color: Colors.indigo,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoTile(
          icon: Icons.badge_outlined,
          title: "Employee ID",
          value: user.empId.isEmpty ? "Not assigned" : user.empId,
        ),
        _InfoTile(icon: Icons.mail_outline, title: "Email", value: user.email),
        _InfoTile(
          icon: Icons.business_outlined,
          title: "Company",
          value: user.companyName,
        ),
        _InfoTile(
          icon: Icons.account_tree_outlined,
          title: "Branch",
          value: user.branchId.isEmpty ? "Not assigned" : user.branchId,
        ),
        const SizedBox(height: 16),
        _SectionHeader(
          title: "Skills",
          actionLabel: "Edit",
          onAction: () => _showEditProfileDialog(context),
        ),
        const SizedBox(height: 8),
        if (user.skills.isEmpty)
          const Text("No skills added yet.")
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.skills
                .map((skill) => Chip(label: Text(skill)))
                .toList(),
          ),
        const SizedBox(height: 20),
        _SectionHeader(
          title: "Performance Signals",
          actionLabel: "Record",
          onAction: () => _showPerformanceDialog(context),
        ),
        const SizedBox(height: 8),
        Text(
          "Only explicit, app-scoped and consented activity snapshots are stored. Keystrokes per hour is calculated from counts only; typed text and system-wide keystrokes are not captured.",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.62),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final skillsController = TextEditingController(
      text: user.skills.join(", "),
    );
    final capacityController = TextEditingController(
      text: user.maxCapacityHoursPerWeek.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: skillsController,
              decoration: const InputDecoration(
                labelText: "Skills",
                hintText: "Flutter, Firebase, Support",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(
                labelText: "Weekly capacity hours",
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = user.copyWith(
                skills: skillsController.text
                    .split(",")
                    .map((skill) => skill.trim())
                    .where((skill) => skill.isNotEmpty)
                    .toList(),
                maxCapacityHoursPerWeek:
                    double.tryParse(capacityController.text.trim()) ??
                    user.maxCapacityHoursPerWeek,
              );
              await onSave(updatedUser);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showPerformanceDialog(BuildContext context) {
    final screenController = TextEditingController(text: "60");
    final focusController = TextEditingController(text: "45");
    final typedController = TextEditingController(text: "0");
    final correctionsController = TextEditingController(text: "0");
    final switchesController = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Record Performance Snapshot"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: screenController,
                decoration: const InputDecoration(
                  labelText: "App screen minutes",
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: focusController,
                decoration: const InputDecoration(labelText: "Focus minutes"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: typedController,
                decoration: const InputDecoration(
                  labelText: "App keystroke count",
                  hintText: "Count only, no typed text",
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: correctionsController,
                decoration: const InputDecoration(labelText: "Corrections"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: switchesController,
                decoration: const InputDecoration(labelText: "Task switches"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await onRecordPerformance(
                user: user,
                appScreenMinutes: int.tryParse(screenController.text) ?? 0,
                focusMinutes: int.tryParse(focusController.text) ?? 0,
                typedCharacters: int.tryParse(typedController.text) ?? 0,
                correctionCount: int.tryParse(correctionsController.text) ?? 0,
                taskSwitches: int.tryParse(switchesController.text) ?? 0,
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Performance snapshot recorded"),
                  ),
                );
              }
            },
            child: const Text("Record"),
          ),
        ],
      ),
    );
  }
}

class _WelcomeBand extends StatelessWidget {
  const _WelcomeBand({required this.user, required this.workloadPercentage});

  final UserModel user;
  final double workloadPercentage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello, ${user.name}!",
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your active task load is ${workloadPercentage.toStringAsFixed(0)}% of weekly capacity.",
            style: TextStyle(
              color: colorScheme.onPrimaryContainer.withOpacity(0.76),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.62),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkloadCard extends StatelessWidget {
  const _WorkloadCard({required this.user, required this.workloadPercentage});

  final UserModel user;
  final double workloadPercentage;

  @override
  Widget build(BuildContext context) {
    final load = (workloadPercentage / 100).clamp(0.0, 1.0).toDouble();
    final color = load >= 0.85
        ? Colors.red
        : load >= 0.65
        ? Colors.orange
        : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "Workload Capacity",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text("${workloadPercentage.toStringAsFixed(0)}%"),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: load,
                minHeight: 10,
                backgroundColor: color.withOpacity(0.14),
                color: color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Weekly capacity: ${user.maxCapacityHoursPerWeek.toStringAsFixed(0)} hours",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.64),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onStatusChanged,
    this.compact = false,
  });

  final TaskModel task;
  final Future<void> Function(TaskModel task, String status) onStatusChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(task.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTaskDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PriorityPill(priority: task.basePriority),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _IconText(
                    icon: Icons.schedule,
                    label:
                        "${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}",
                  ),
                  _IconText(
                    icon: Icons.timer_outlined,
                    label: _formatDuration(task.estimatedDurationMinutes),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      task.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (task.status != "Completed")
                    TextButton.icon(
                      onPressed: () => _showSubmitTaskDialog(context),
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text("Submit"),
                    ),
                  _StatusMenu(
                    status: task.status,
                    onChanged: (status) => onStatusChanged(task, status),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 18),
            _InfoTile(
              icon: Icons.calendar_today_outlined,
              title: "Due window",
              value:
                  "${_formatDateLabel(task.startTime)} ${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}",
            ),
            _InfoTile(
              icon: Icons.flag_outlined,
              title: "Priority",
              value: task.basePriority.isEmpty ? "Normal" : task.basePriority,
            ),
            _InfoTile(
              icon: Icons.psychology_outlined,
              title: "Required skills",
              value: task.requiredSkills.isEmpty
                  ? "No specific skills"
                  : task.requiredSkills.join(", "),
            ),
            if (task.submissionNote.isNotEmpty)
              _InfoTile(
                icon: Icons.upload_file_outlined,
                title: "Submission",
                value: task.submissionNote,
              ),
            if (task.reviewerFeedback.isNotEmpty)
              _InfoTile(
                icon: Icons.rate_review_outlined,
                title: "Reviewer feedback",
                value: task.reviewerFeedback,
              ),
            _InfoTile(
              icon: Icons.auto_awesome_outlined,
              title: "AI follow-up",
              value: AiService().taskFollowUp(task),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final opened = await CalendarService().openGoogleCalendar(
                    task,
                  );
                  if (!context.mounted || opened) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Google Calendar link copied. Paste it in a browser to add this task.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text("Add to Google Calendar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubmitTaskDialog(BuildContext context) {
    final noteController = TextEditingController(text: task.submissionNote);
    final linkController = TextEditingController(text: task.submissionLink);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Submit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Work summary",
                hintText: "What was completed?",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(
                labelText: "Proof / file link",
                hintText: "Drive, GitHub, ticket, document link",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final vm = Provider.of<EmployeeViewModel>(context, listen: false);
              await vm.submitTask(
                task: task,
                note: noteController.text.trim(),
                link: linkController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Task submitted for review")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}

class _TimelineTaskTile extends StatelessWidget {
  const _TimelineTaskTile({required this.task, required this.onStatusChanged});

  final TaskModel task;
  final Future<void> Function(TaskModel task, String status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(task.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              _formatTime(task.startTime),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              Container(width: 2, height: 72, color: color.withOpacity(0.22)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${_formatTime(task.startTime)} - ${_formatTime(task.endTime)}",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.62),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StatusMenu(
                      status: task.status,
                      onChanged: (status) => onStatusChanged(task, status),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMenu extends StatelessWidget {
  const _StatusMenu({required this.status, required this.onChanged});

  final String status;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const allowedStatuses = [
      "Pending",
      "In Progress",
      "Submitted",
      "Completed",
    ];
    final selectedStatus = allowedStatuses.contains(status)
        ? status
        : allowedStatuses.first;

    return DropdownButton<String>(
      value: selectedStatus,
      underline: const SizedBox(),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: allowedStatuses.map((value) {
        return DropdownMenuItem<String>(
          value: value,
          enabled: value != "Completed",
          child: Text(
            value,
            style: TextStyle(
              color: value == "Completed" ? Colors.grey : _statusColor(value),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null && newStatus != status) {
          onChanged(newStatus);
        }
      },
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = _priorityColor(priority);
    final label = priority.isEmpty ? "Normal" : priority;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primary,
              child: Text(
                _initialsFor(user.name),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.role,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.64),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.62)),
            ),
          ],
        ),
      ),
    );
  }
}

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r"\s+"))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return "?";
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return "${parts.first[0]}${parts.last[0]}".toUpperCase();
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, "0");
  final period = dateTime.hour >= 12 ? "PM" : "AM";
  return "$hour:$minute $period";
}

String _formatDateLabel(DateTime dateTime) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  final today = DateTime.now();
  final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
  final current = DateTime(today.year, today.month, today.day);
  if (date == current) return "Today";
  if (date == current.add(const Duration(days: 1))) return "Tomorrow";
  return "${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}";
}

String _formatDuration(int minutes) {
  if (minutes <= 0) return "Flexible";
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;
  if (hours == 0) return "${remainingMinutes}m";
  if (remainingMinutes == 0) return "${hours}h";
  return "${hours}h ${remainingMinutes}m";
}

Color _statusColor(String status) {
  switch (status) {
    case "In Progress":
      return Colors.blue;
    case "Submitted":
      return Colors.purple;
    case "Completed":
      return Colors.green;
    case "Pending":
    default:
      return Colors.orange;
  }
}

Color _priorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case "critical":
      return Colors.red;
    case "high":
      return Colors.deepOrange;
    case "medium":
      return Colors.indigo;
    case "low":
      return Colors.green;
    default:
      return Colors.blueGrey;
  }
}

double _calculateWorkloadPercentage(UserModel user, List<TaskModel> tasks) {
  final capacityMinutes =
      (user.maxCapacityHoursPerWeek <= 0 ? 40 : user.maxCapacityHoursPerWeek) *
      60;
  final activeMinutes = tasks
      .where(
        (task) => task.assignedTo == user.userId && task.status != "Completed",
      )
      .fold<int>(0, (total, task) {
        if (task.estimatedDurationMinutes > 0) {
          return total + task.estimatedDurationMinutes;
        }
        final minutes = task.endTime.difference(task.startTime).inMinutes;
        return total + minutes.clamp(0, 24 * 60);
      });
  return (activeMinutes / capacityMinutes * 100).clamp(0, 100).toDouble();
}
