import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_flow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:task_flow/features/workspace/presentation/screens/workspace_list_screen.dart';
import 'package:task_flow/features/profile/presentation/screens/profile_screen.dart';
import 'package:task_flow/features/project/presentation/screens/projects_screen.dart';
import 'package:task_flow/features/task/presentation/screens/tasks_screen.dart';
// Page transitions will be used in future implementations

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _children = [
    const DashboardScreen(),
    const WorkspaceListScreen(),
    const ProjectsScreen(),
    const TasksScreen(),
    const ProfileScreen(),
  ];

  void onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildFloatingActionButton() {
    // Different FABs for different screens
    switch (_currentIndex) {
      case 1: // Workspaces
        return FloatingActionButton(
          onPressed: () {
            // Create new workspace
          },
          child: const Icon(Icons.add_business),
        ).animate().scale(duration: 300.ms);
      case 2: // Projects
        return FloatingActionButton(
          onPressed: () {
            // Create new project
          },
          child: const Icon(Icons.add_box),
        ).animate().scale(duration: 300.ms);
      case 3: // Tasks
        return FloatingActionButton(
          onPressed: () {
            // Create new task
          },
          child: const Icon(Icons.add_task),
        ).animate().scale(duration: 300.ms);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Workspaces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}