import 'package:flutter/material.dart';
import 'package:task_flow/features/profile/presentation/screens/profile_screen.dart';
import 'package:task_flow/features/workspace/presentation/screens/workspace_list_screen.dart';
import 'package:task_flow/features/project/presentation/screens/project_list_screen.dart';
import 'package:task_flow/features/task/presentation/screens/kanban_board_screen.dart';

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
            ElevatedButton(
              onPressed: () {
                // Navigate to workspaces
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
                // Navigate to projects
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProjectListScreen(),
                  ),
                );
              },
              child: const Text('Projects'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to Kanban board
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KanbanBoardScreen(),
                  ),
                );
              },
              child: const Text('Kanban Board'),
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