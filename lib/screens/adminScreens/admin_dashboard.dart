import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../viewmodels/admin_viewmodel.dart';

class CompanyAdminDashboard extends StatefulWidget {
  const CompanyAdminDashboard({super.key});
  @override
  State<CompanyAdminDashboard> createState() => _CompanyAdminDashboardState();
}

class _CompanyAdminDashboardState extends State<CompanyAdminDashboard> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Company Overview",
    "Task Management",
    "Team Monitoring",
    "Branches",
    "Settings"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildDrawerHeader(colorScheme),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavTile(context, Icons.dashboard, "Dashboard", 0),
                  _buildNavTile(context, Icons.assignment, "Tasks", 1),
                  _buildNavTile(context, Icons.people, "Team", 2),
                  _buildNavTile(context, Icons.home_filled, "Branches", 3),
                  _buildNavTile(context, Icons.settings, "Settings", 4)
                ],
              ),
            ),
            const Divider(),
            _buildNavTile(context, Icons.logout, "Logout", -1, isLogout: true),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _AdminOverviewScreen(),
          _TaskManagementScreen(),
          _TeamMonitoringScreen(),
          _ManageBranchesScreen(),
          _CompanySettingScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context, viewModel),
              child: const Icon(Icons.add_task),
            )
          : null,
    );
  }

  void _showAddTaskDialog(BuildContext context, AdminViewModel vm) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final skillsController = TextEditingController();
    String priority = "Medium";
    String? assignedToId;
    DateTime startTime = DateTime.now().add(const Duration(hours: 1));
    DateTime endTime = DateTime.now().add(const Duration(hours: 3));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Create New Task"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Task Title"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: skillsController,
                  decoration: const InputDecoration(
                    labelText: "Required Skills (comma separated)",
                    prefixIcon: Icon(Icons.psychology),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final skills = skillsController.text
                          .split(",")
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList();
                      vm.getAIRecommendations(
                        requiredSkills: skills,
                        startTime: startTime,
                        endTime: endTime,
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Get Smart Recommendations"),
                  ),
                ),
                if (vm.isLoadingRecommendations)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (vm.smartRecommendations.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text("AI Suggestions:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vm.smartRecommendations.length,
                      itemBuilder: (context, index) {
                        final rec = vm.smartRecommendations[index];
                        final isSelected = assignedToId == rec['userId'];
                        return GestureDetector(
                          onTap: () => setDialogState(() => assignedToId = rec['userId']),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8, top: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
                              border: Border.all(color: isSelected ? colorScheme.primary : colorScheme.outline),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(rec['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                                Text("Score: ${rec['score']}", style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text(rec['isAvailable'] ? "Available" : "Busy", style: TextStyle(color: rec['isAvailable'] ? Colors.green : Colors.red, fontSize: 9)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                StreamBuilder<List<UserModel>>(
                  stream: vm.employeesStream,
                  builder: (context, snapshot) {
                    final employees = snapshot.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: assignedToId,
                      hint: const Text("Assign To Employee"),
                      items: employees
                          .map((e) => DropdownMenuItem(
                              value: e.userId, child: Text(e.name)))
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => assignedToId = val),
                      decoration: const InputDecoration(labelText: "Assignee"),
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  items: ["Low", "Medium", "High", "Critical"]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => priority = val!),
                  decoration: const InputDecoration(labelText: "Priority"),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text("Start Time"),
                  subtitle: Text(startTime.toString().substring(0, 16)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: startTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startTime),
                      );
                      if (time != null) {
                        setDialogState(() {
                          startTime = DateTime(
                              date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
                ListTile(
                  title: const Text("End Time"),
                  subtitle: Text(endTime.toString().substring(0, 16)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: endTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endTime),
                      );
                      if (time != null) {
                        setDialogState(() {
                          endTime = DateTime(
                              date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (assignedToId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please assign to an employee")),
                  );
                  return;
                }
                final result = await vm.addTask(
                  title: titleController.text,
                  description: descController.text,
                  assignedTo: assignedToId!,
                  startTime: startTime,
                  endTime: endTime,
                  basePriority: priority,
                  branchId: "Main",
                  assignedBy: vm.currentUserId ?? "Admin",
                  requiredSkills: skillsController.text
                      .split(",")
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                );

                if (context.mounted) {
                  if (result == "success") {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Task created successfully")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                }
              },
              child: const Text("Create Task"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ColorScheme colorScheme) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.secondary, colorScheme.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.business, color: Colors.white, size: 35),
          ),
          SizedBox(height: 15),
          Text(
            'Techcadd Admin',
            style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Text(
            'Company Workspace',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, IconData icon, String title, int index, {bool isLogout = false}) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : (isSelected ? colorScheme.secondary : colorScheme.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isLogout ? Colors.red : (isSelected ? colorScheme.secondary : colorScheme.onSurface),
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (isLogout) {
          Navigator.pop(context);
        } else {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        }
      },
    );
  }
}

class _ManageBranchesScreen extends StatelessWidget {
  const _ManageBranchesScreen({super.key});
  @override
  Widget build(BuildContext context){
    return const Center(child: Text("Manage Branches Screen"));
  }
}

class _CompanySettingScreen extends StatelessWidget {
  const _CompanySettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);
    
    return StreamBuilder<UserModel>(
      stream: viewModel.AdminProfile, 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SettingSkeleton();
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No Profile Found"));
        }

        final admin = snapshot.data!;
        final timeDisplay = "${viewModel.startHour.format(context)} - ${viewModel.endHour.format(context)}";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Admin Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                enabled: false,
                initialValue: admin.name,
                decoration: const InputDecoration(
                  label: Text("Full Name"),
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: false,
                initialValue: admin.email,
                decoration: const InputDecoration(
                  label: Text("Email Address"),
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Operational Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pickHours(context, viewModel),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: TextEditingController(text: timeDisplay),
                    decoration: const InputDecoration(
                      label: Text("Set Working Hours"),
                      prefixIcon: Icon(Icons.timer),
                      hintText: "Company Working Hours",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  Future<void> _pickHours(BuildContext context, AdminViewModel vm) async {
    final TimeOfDay? start = await showTimePicker(
      context: context,
      initialTime: vm.startHour,
      helpText: "Select Start of Work Day",
    );
    if (start == null) return;

    if (context.mounted) {
      final TimeOfDay? end = await showTimePicker(
        context: context,
        initialTime: vm.endHour,
        helpText: "Select End of Work Day",
      );
      if (end != null) {
        vm.updateWorkingHours(start, end);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Working Hours set: ${start.format(context)} - ${end.format(context)}"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}

class _SettingSkeleton extends StatelessWidget {
  const _SettingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceVariant,
      highlightColor: colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 120, height: 20, color: Colors.white),
            const SizedBox(height: 20),
            ...List.generate(2, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8)
                ),
              ),
            )),
            const SizedBox(height: 24),
            Container(width: 150, height: 20, color: Colors.white),
            const SizedBox(height: 20),
            Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(8)
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _AdminOverviewScreen extends StatelessWidget {
  const _AdminOverviewScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Team Performance",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          StreamBuilder<List<TaskModel>>(
              stream: viewModel.tasksStream,
              builder: (context, taskSnapshot) {
                final activeTasks = taskSnapshot.data
                        ?.where((t) => t.status != 'Completed')
                        .length ??
                    0;
                return StreamBuilder<List<UserModel>>(
                    stream: viewModel.employeesStream,
                    builder: (context, empSnapshot) {
                      final teamSize = empSnapshot.data?.length ?? 0;
                      return Column(
                        children: [
                          Row(
                            children: [
                              _buildStatCard(context, "Active Tasks",
                                  "$activeTasks", Icons.task, Colors.blue),
                              const SizedBox(width: 16),
                              _buildStatCard(context, "Team Size", "$teamSize",
                                  Icons.people, Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(context, "Company ID",
                              viewModel.currentCompanyId ?? "N/A",
                              Icons.business, Colors.green,
                              fullWidth: true),
                        ],
                      );
                    });
              }),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, {bool fullWidth = false}) {
    final card = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
  }
}

class _TaskManagementScreen extends StatelessWidget {
  const _TaskManagementScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);
    return StreamBuilder<List<TaskModel>>(
      stream: viewModel.tasksStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No tasks found. Click + to create."));
        
        final tasks = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.assignment, color: _getPriorityColor(task.basePriority)),
                title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Status: ${task.status} • Assigned to: ${task.assignedTo}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => viewModel.removeTask(task.taskId),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical': return Colors.red;
      case 'High': return Colors.orange;
      case 'Medium': return Colors.blue;
      default: return Colors.green;
    }
  }
}

class _TeamMonitoringScreen extends StatelessWidget {
  const _TeamMonitoringScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);
    return StreamBuilder<List<UserModel>>(
      stream: viewModel.employeesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No employees found. Invite them in Settings."));
        
        final employees = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final emp = employees[index];
            final initials = emp.name.isNotEmpty ? emp.name[0] : "?";
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(initials, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                ),
                title: Text(emp.name),
                subtitle: Text("${emp.role} • ${emp.email}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${emp.currentWorkloadPercentage.toStringAsFixed(0)}%", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("Load", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
