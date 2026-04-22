import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/apptheme.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});
  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Super Admin Dashboard"),
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          SizedBox(
            height: 200,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.admin_panel_settings, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'AIQ - Super Admin',
                    style: AppTheme.lightTheme.textTheme.titleLarge!.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildGlossyTile(
            context,
            title: '  Dashboard',
            icon: Icons.dashboard,
            onTap: () => Navigator.pop(context),
          ),
          _buildGlossyTile(
            context,
            title: 'Companies',
            icon: Icons.business,
            onTap: () => Navigator.pop(context),
          ),
          _buildGlossyTile(
            context,
            title: 'Your Profile',
            icon: Icons.person,
            onTap: () => Navigator.pop(context),
          ),
          const Divider(indent: 20, endIndent: 20),
          _buildGlossyTile(
            context,
            title: 'Logout',
            icon: Icons.logout,
            onTap: () => Navigator.pop(context),
            isLogout: true,
          ),
        ]),
      ),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              //For Graphs
              Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                  ),
                  child: const Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: Center(child: Text("Analytics Chart Placeholder")),
                  )),
              const SizedBox(height: 10),
            ],
          )),
    );
  }

  Widget _buildGlossyTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          // Glossy effect with subtle gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withOpacity(0.7),
            ],
          ),
          // Elevated feel with soft shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colorScheme.onSurface.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isLogout ? Colors.redAccent : colorScheme.primary,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLogout ? Colors.redAccent : colorScheme.onSurface,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          onTap: onTap,
        ),
      ),
    );
  }
}
