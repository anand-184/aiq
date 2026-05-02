import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../viewmodels/employee_viewmodel.dart';

class EmpHomescreen extends StatefulWidget {
  const EmpHomescreen({super.key});
  @override
  State<EmpHomescreen> createState() => _EmpHomescreenState();
}

class _EmpHomescreenState extends State<EmpHomescreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<EmployeeViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Portal"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Sign out logic could be added here or in login logic
              Navigator.pushReplacementNamed(context, '/login');
            },
          )
        ],
      ),
      body: StreamBuilder<UserModel>(
        stream: viewModel.profileStream,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (profileSnapshot.hasError || !profileSnapshot.hasData) {
            return const Center(child: Text("Error loading profile"));
          }

          final user = profileSnapshot.data!;

          return StreamBuilder<List<TaskModel>>(
            stream: viewModel.myTasksStream,
            builder: (context, taskSnapshot) {
              if (taskSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final tasks = taskSnapshot.data ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(user, colorScheme),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text("My Current Tasks", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    if (tasks.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No tasks assigned for today."),
                      ))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _buildTaskCard(context, viewModel, task, colorScheme);
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(UserModel user, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello, ${user.name}!", 
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
          const SizedBox(height: 8),
          Text("You have a workload of ${user.currentWorkloadPercentage.toStringAsFixed(0)}% today.",
            style: TextStyle(fontSize: 16, color: colorScheme.onPrimaryContainer.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, EmployeeViewModel vm, TaskModel task, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${task.startTime.hour}:00 - ${task.endTime.hour}:00", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: _buildStatusDropdown(vm, task),
      ),
    );
  }

  Widget _buildStatusDropdown(EmployeeViewModel vm, TaskModel task) {
    return DropdownButton<String>(
      value: task.status,
      underline: const SizedBox(),
      icon: const Icon(Icons.keyboard_arrow_down),
      items: ["Pending", "In Progress", "Completed"].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(
            color: _getStatusColor(value),
            fontWeight: FontWeight.bold,
            fontSize: 12
          )),
        );
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null) {
          vm.updateTaskStatus(task, newStatus);
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress': return Colors.blue;
      case 'Completed': return Colors.green;
      case 'Pending':
      default: return Colors.orange;
    }
  }
}
