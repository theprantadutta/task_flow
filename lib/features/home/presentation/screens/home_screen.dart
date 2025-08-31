import 'package:flutter/material.dart';
import 'package:task_flow/features/profile/presentation/screens/profile_screen.dart';
import 'package:task_flow/features/workspace/presentation/screens/workspace_list_screen.dart';
import 'package:task_flow/features/project/presentation/screens/project_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to profile screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to TaskFlow',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to workspace list
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WorkspaceListScreen(),
                  ),
                );
              },
              child: const Text('Workspaces'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to projects list
                // For demo purposes, we'll use a default workspace ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectListScreen(
                      workspaceId: 'demo_workspace_id',
                    ),
                  ),
                );
              },
              child: const Text('Projects'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new workspace or project
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}