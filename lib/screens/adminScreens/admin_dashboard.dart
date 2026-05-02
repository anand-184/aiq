import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../login_screen.dart';
import '../../models/branch.dart';
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
    "Workload Scheduler",
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
                  _buildNavTile(context, Icons.calendar_month, "Scheduler", 4),
                  _buildNavTile(context, Icons.settings, "Settings", 5)
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
          _WorkloadSchedulerScreen(),
          _CompanySettingScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context, viewModel),
              child: const Icon(Icons.add_task),
            )
          : _selectedIndex == 2
              ? FloatingActionButton(
                  onPressed: () => _showAddMemberDialog(context, viewModel),
                  child: const Icon(Icons.person_add),
                )
              : null,
    );
  }

  void _showAddMemberDialog(BuildContext context, AdminViewModel vm) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final skillController = TextEditingController();
    String role = "Employee";
    String? selectedBranchId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Team Member"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Initial Password"),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Branch>>(
                  stream: vm.branchesStream,
                  builder: (context, snapshot) {
                    final branches = snapshot.data ?? [];
                    final items = <DropdownMenuItem<String>>[];
                    final seenIds = <String>{};

                    for (var b in branches) {
                      final id = b.branchId ?? "";
                      if (id.isNotEmpty && seenIds.add(id)) {
                        items.add(DropdownMenuItem(
                            value: id, child: Text(b.branchName)));
                      }
                    }

                    // Safety check: Ensure selected value exists and is unique
                    if (selectedBranchId != null &&
                        selectedBranchId!.isNotEmpty &&
                        !seenIds.contains(selectedBranchId)) {
                      items.add(DropdownMenuItem(
                          value: selectedBranchId,
                          child: Text("Branch: $selectedBranchId")));
                    }

                    return DropdownButtonFormField<String>(
                      value: (selectedBranchId != null &&
                              selectedBranchId!.isNotEmpty)
                          ? selectedBranchId
                          : null,
                      hint: const Text("Select Branch"),
                      items: items,
                      onChanged: (val) =>
                          setDialogState(() => selectedBranchId = val),
                      decoration: const InputDecoration(labelText: "Branch"),
                    );
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  items: ["Employee", "Manager"]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => role = val!),
                  decoration: const InputDecoration(labelText: "Role"),
                ),
                TextField(
                  controller: skillController,
                  decoration: const InputDecoration(
                      labelText: "Skills (Comma separated)"),
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
                if (selectedBranchId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a branch")),
                  );
                  return;
                }
                final result = await vm.addEmployee(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  name: nameController.text.trim(),
                  role: role,
                  branchId: selectedBranchId!,
                  skills: skillController.text
                      .split(",")
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList(),
                );

                if (context.mounted) {
                  if (result == "success") {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Member added successfully")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                }
              },
              child: const Text("Add Member"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, AdminViewModel vm) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String priority = "Medium";
    String? assignedToId;
    String? selectedBranchId;
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
                StreamBuilder<List<Branch>>(
                  stream: vm.branchesStream,
                  builder: (context, snapshot) {
                    final branches = snapshot.data ?? [];
                    final items = <DropdownMenuItem<String>>[];
                    final seenIds = <String>{};

                    for (var b in branches) {
                      final id = b.branchId ?? "";
                      if (id.isNotEmpty && seenIds.add(id)) {
                        items.add(DropdownMenuItem(
                            value: id, child: Text(b.branchName)));
                      }
                    }

                    // Safety check: Ensure selected value exists and is unique
                    if (selectedBranchId != null &&
                        selectedBranchId!.isNotEmpty &&
                        !seenIds.contains(selectedBranchId)) {
                      items.add(DropdownMenuItem(
                          value: selectedBranchId,
                          child: Text("Branch: $selectedBranchId")));
                    }

                    return DropdownButtonFormField<String>(
                      value: (selectedBranchId != null &&
                              selectedBranchId!.isNotEmpty)
                          ? selectedBranchId
                          : null,
                      hint: const Text("Select Branch"),
                      items: items,
                      onChanged: (val) =>
                          setDialogState(() => selectedBranchId = val),
                      decoration: const InputDecoration(labelText: "Branch"),
                    );
                  },
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<UserModel>>(
                  stream: vm.employeesStream,
                  builder: (context, snapshot) {
                    final employees = snapshot.data ?? [];
                    final items = <DropdownMenuItem<String>>[];
                    final seenIds = <String>{};

                    for (var e in employees) {
                      if (seenIds.add(e.userId)) {
                        items.add(DropdownMenuItem(
                            value: e.userId, child: Text(e.name)));
                      }
                    }

                    if (assignedToId != null && !seenIds.contains(assignedToId)) {
                      items.add(DropdownMenuItem(
                          value: assignedToId, child: Text("ID: $assignedToId")));
                    }

                    return DropdownButtonFormField<String>(
                      value: assignedToId,
                      hint: const Text("Assign To Employee"),
                      items: items,
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
                if (assignedToId == null || selectedBranchId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a branch and an employee")),
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
                  branchId: selectedBranchId!,
                  assignedBy: vm.currentUserId ?? "Admin",
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
      onTap: () async {
        if (isLogout) {
          final vm = Provider.of<AdminViewModel>(context, listen: false);
          await vm.logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        } else {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        }
      },
    );
  }
}

class _WorkloadSchedulerScreen extends StatefulWidget {
  const _WorkloadSchedulerScreen({super.key});

  @override
  State<_WorkloadSchedulerScreen> createState() => _WorkloadSchedulerScreenState();
}

class _WorkloadSchedulerScreenState extends State<_WorkloadSchedulerScreen> {
  UserModel? selectedMember;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      body: Row(
        children: [
          // Left Side: Team Member List
          Container(
            width: 250,
            child: StreamBuilder<List<UserModel>>(
              stream: viewModel.employeesStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final members = snapshot.data!;
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isSelected = selectedMember?.userId == member.userId;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      leading: CircleAvatar(child: Text(member.name[0])),
                      title: Text(member.name),
                      onTap: () => setState(() => selectedMember = member),
                    );
                  },
                );
              },
            ),
          ),
          // Right Side: Hourly Slots
          Expanded(
            child: selectedMember == null
                ? const Center(child: Text("Select a team member to view their schedule"))
                : _buildHourlySlots(viewModel, selectedMember!),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySlots(AdminViewModel vm, UserModel member) {
    // Generate hours from startHour to endHour (e.g., 9 AM to 6 PM)
    final start = vm.startHour.hour;
    final end = vm.endHour.hour;

    return StreamBuilder<List<TaskModel>>(
      stream: vm.tasksStream,
      builder: (context, snapshot) {
        final tasks = snapshot.data?.where((t) => t.assignedTo == member.userId).toList() ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: (end - start) + 1,
          itemBuilder: (context, index) {
            final hour = start + index;
            final timeLabel = "${hour > 12 ? hour - 12 : hour} ${hour >= 12 ? 'PM' : 'AM'}";

            // Find all tasks that overlap with this hour slot
            final tasksInSlot = tasks.where(
              (t) => t.startTime.hour <= hour && t.endTime.hour > hour,
            ).toList();

            final isBusy = tasksInSlot.isNotEmpty;

            return InkWell(
              onTap: isBusy 
                ? () => showEditTaskDialog(context, vm, tasksInSlot.first)
                : () => _showAddTaskForSlot(context, vm, member, hour),
              child: Container(
                height: 80,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isBusy ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isBusy ? Colors.blue : Colors.transparent),
                ),
                child: ListTile(
                  leading: SizedBox(
                    width: 60, 
                    child: Text(timeLabel, style: const TextStyle(fontWeight: FontWeight.bold))
                  ),
                  title: isBusy
                    ? Text(tasksInSlot.map((e) => e.title).join(", "), 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)
                    : const Text("Free Slot", style: TextStyle(color: Colors.grey)),
                  subtitle: isBusy 
                    ? Text("${tasksInSlot.length} task(s) active") 
                    : const Text("Tap to assign task"),
                  trailing: isBusy 
                    ? const Icon(Icons.lock, color: Colors.blue) 
                    : const Icon(Icons.add_circle_outline, color: Colors.grey),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTaskForSlot(BuildContext context, AdminViewModel vm, UserModel member, int hour) {
    // We need to access _showAddTaskDialog from CompanyAdminDashboard, 
    // but since we are in a sub-widget state, we'll implement a simplified version or just call a helper.
    // For now, let's just use the existing logic in a reusable way or duplicate briefly for context.
    
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, hour, 0);
    final endTime = startTime.add(const Duration(hours: 1));

    // To use the existing _showAddTaskDialog, we'd need it to be accessible.
    // Let's create a static helper or move it.
    // For simplicity in this edit, I'll implement a quick 'Quick Task' dialog.
    
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quick Task for ${member.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Time: ${hour}:00 - ${hour+1}:00"),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Task Title", hintText: "e.g., Client Meeting"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              
              final result = await vm.addTask(
                title: titleController.text,
                description: "Scheduled via Workload Planner",
                assignedTo: member.userId,
                startTime: startTime,
                endTime: endTime,
                basePriority: "Medium",
                branchId: member.branchId,
                assignedBy: vm.currentUserId ?? "Admin",
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                if (result != "success") {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
                }
              }
            },
            child: const Text("Schedule"),
          )
        ],
      ),
    );
  }
}

class _ManageBranchesScreen extends StatelessWidget {
  const _ManageBranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AdminViewModel>(context);

    return Scaffold(
      body: StreamBuilder<List<Branch>>(
        stream: viewModel.branchesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No branches found. Click + to add."));
          }

          final branches = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.home_filled)),
                  title: Text(branch.branchName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () => _showEditBranchDialog(context, viewModel, branch),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => viewModel.removeBranch(branch.branchId!),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBranchDialog(context, viewModel),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  void _showEditBranchDialog(
      BuildContext context, AdminViewModel vm, Branch branch) {
    final controller = TextEditingController(text: branch.branchName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Branch"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Branch Name"),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final updatedBranch = branch.copyWith(name: controller.text);
                await vm.updateBranch(updatedBranch);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showAddBranchDialog(BuildContext context, AdminViewModel vm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Branch"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Branch Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final result = await vm.addBranch(controller.text);
                if (context.mounted) {
                  if (result != "success") {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
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
                          _buildStatCard(context, "Company",
                              viewModel.currentCompanyName ?? "Loading...",
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
                onTap: () => showEditTaskDialog(context, viewModel, task),
                leading: Icon(Icons.assignment,
                    color: getPriorityColor(task.basePriority)),
                title: Text(task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    Text("Status: ${task.status} • Assigned to: ${task.assignedTo}"),
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
}

Color getPriorityColor(String priority) {
  switch (priority) {
    case 'Critical': return Colors.red;
    case 'High': return Colors.orange;
    case 'Medium': return Colors.blue;
    default: return Colors.green;
  }
}

void showEditTaskDialog(BuildContext context, AdminViewModel vm, TaskModel task) {
  final titleController = TextEditingController(text: task.title);
  final descController = TextEditingController(text: task.description);
  String priority = task.basePriority;
  String? assignedToId = task.assignedTo;
  String? selectedBranchId = task.branchId;
  DateTime startTime = task.startTime;
  DateTime endTime = task.endTime;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text("Edit Task"),
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
              StreamBuilder<List<Branch>>(
                stream: vm.branchesStream,
                builder: (context, snapshot) {
                  final branches = snapshot.data ?? [];
                  final items = <DropdownMenuItem<String>>[];
                  final seenIds = <String>{};

                  for (var b in branches) {
                    final id = b.branchId ?? "";
                    if (id.isNotEmpty && seenIds.add(id)) {
                      items.add(DropdownMenuItem(
                          value: id, child: Text(b.branchName)));
                    }
                  }

                  // Safety check: Ensure selected value exists and is unique
                  if (selectedBranchId != null &&
                      selectedBranchId!.isNotEmpty &&
                      !seenIds.contains(selectedBranchId)) {
                    items.add(DropdownMenuItem(
                        value: selectedBranchId,
                        child: Text("Branch: $selectedBranchId")));
                  }

                  return DropdownButtonFormField<String>(
                    value: (selectedBranchId != null &&
                            selectedBranchId!.isNotEmpty)
                        ? selectedBranchId
                        : null,
                    hint: const Text("Select Branch"),
                    items: items,
                    onChanged: (val) =>
                        setDialogState(() => selectedBranchId = val),
                    decoration: const InputDecoration(labelText: "Branch"),
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<UserModel>>(
                stream: vm.employeesStream,
                builder: (context, snapshot) {
                  final employees = snapshot.data ?? [];
                  final items = <DropdownMenuItem<String>>[];
                  final seenIds = <String>{};

                  for (var e in employees) {
                    if (e.userId.isNotEmpty && seenIds.add(e.userId)) {
                      items.add(DropdownMenuItem(
                          value: e.userId, child: Text(e.name)));
                    }
                  }

                  if (assignedToId != null &&
                      assignedToId!.isNotEmpty &&
                      !seenIds.contains(assignedToId)) {
                    items.add(DropdownMenuItem(
                        value: assignedToId,
                        child: Text("Employee: $assignedToId")));
                  }

                  return DropdownButtonFormField<String>(
                    value: (assignedToId != null && assignedToId!.isNotEmpty)
                        ? assignedToId
                        : null,
                    hint: const Text("Assign To Employee"),
                    items: items,
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
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(startTime),
                    );
                    if (time != null) {
                      setDialogState(() {
                        startTime = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);
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
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(endTime),
                    );
                    if (time != null) {
                      setDialogState(() {
                        endTime = DateTime(date.year, date.month, date.day,
                            time.hour, time.minute);
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
              final updatedTask = task.copyWith(
                title: titleController.text,
                description: descController.text,
                assignedTo: assignedToId,
                branchId: selectedBranchId,
                basePriority: priority,
                startTime: startTime,
                endTime: endTime,
                estimatedDurationMinutes: endTime.difference(startTime).inMinutes,
              );
              await vm.updateTask(updatedTask);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Update Task"),
          ),
        ],
      ),
    ),
  );
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
                onTap: () => _showEditMemberDialog(context, viewModel, emp),
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(initials,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ),
                title: Text(emp.name),
                subtitle: Text("${emp.role} • ${emp.email}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [

                        Text("${emp.currentWorkloadPercentage.toStringAsFixed(0)}%",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Load", style: TextStyle(fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.person_remove_outlined, color: Colors.red),
                      onPressed: () => _confirmRemoveEmployee(context, viewModel, emp),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditMemberDialog(
      BuildContext context, AdminViewModel vm, UserModel emp) {
    final roleController = TextEditingController(text: emp.role);
    final skillController = TextEditingController(text: emp.skills.join(", "));
    final capacityController =
        TextEditingController(text: emp.maxCapacityHoursPerWeek.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${emp.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: "Role")),
            TextField(
                controller: skillController,
                decoration: const InputDecoration(
                    labelText: "Skills (Comma separated)")),
            TextField(
                controller: capacityController,
                decoration:
                    const InputDecoration(labelText: "Weekly Capacity (Hours)"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final updatedEmp = emp.copyWith(
                role: roleController.text,
                skills: skillController.text
                    .split(",")
                    .map((s) => s.trim())
                    .toList(),
                maxCapacityHoursPerWeek:
                    double.tryParse(capacityController.text) ?? 40,
              );
              await vm.updateEmployee(updatedEmp);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  void _confirmRemoveEmployee(
      BuildContext context, AdminViewModel vm, UserModel emp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Employee"),
        content: Text("Are you sure you want to remove ${emp.name} from the company?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await vm.removeEmployee(emp);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
