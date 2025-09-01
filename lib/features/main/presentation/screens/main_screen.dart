import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:task_flow/features/workspace/presentation/screens/workspace_list_screen.dart';
import 'package:task_flow/features/profile/presentation/screens/profile_screen.dart';
import 'package:task_flow/features/project/presentation/screens/projects_screen.dart';
import 'package:task_flow/features/task/presentation/screens/tasks_screen.dart';
import 'package:task_flow/features/workspace/widgets/create_workspace_form.dart';
import 'package:task_flow/features/project/widgets/create_project_form.dart';
import 'package:task_flow/shared/services/workspace_service.dart';
import 'package:task_flow/shared/services/project_service.dart';
import 'package:task_flow/shared/widgets/enhanced_bottom_navigation_bar.dart';
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

  Future<void> _showCreateWorkspaceDialog() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Create Workspace'),
            content: CreateWorkspaceForm(
              ownerId: user.uid,
              onCreate: (workspace) async {
                try {
                  final workspaceService = WorkspaceService();
                  await workspaceService.createWorkspace(
                    name: workspace.name,
                    ownerId: user.uid,
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // Close the dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workspace created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // If we're currently on the workspace screen, trigger a refresh
                    // We do this by setting the state which will rebuild the screen
                    if (_currentIndex == 1) {
                      // Access the WorkspaceListScreen state and call _loadWorkspaces
                      // This is a bit of a hack, but it works for now
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        // Rebuild the current screen to trigger data refresh
                        setState(() {});
                      });
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create workspace: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          );
        },
      );
    }
  }

  Future<void> _showCreateProjectDialog() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    try {
      final workspaceService = WorkspaceService();
      final workspaces = await workspaceService.getUserWorkspaces(user.uid);

      if (workspaces.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please create a workspace first'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      String? selectedWorkspaceId = workspaces.isNotEmpty ? workspaces.first.id : null;

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Create Project'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedWorkspaceId,
                        items: workspaces.map((workspace) {
                          return DropdownMenuItem(
                            value: workspace.id,
                            child: Text(workspace.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedWorkspaceId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Workspace',
                        ),
                      ),
                      const SizedBox(height: 16),
                      CreateProjectForm(
                        workspaceId: selectedWorkspaceId ?? '',
                        ownerId: user.uid,
                        onCreate: (project) async {
                          if (selectedWorkspaceId == null) return;

                          try {
                            final projectService = ProjectService();
                            await projectService.createProject(
                              workspaceId: selectedWorkspaceId!,
                              name: project.name,
                              description: project.description,
                              ownerId: user.uid,
                            );

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext); // Close the dialog

                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Project created successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to create project: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load workspaces: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateTaskMessage() {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tasks are created within projects'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Widget _buildFloatingActionButton() {
    // Different FABs for different screens
    switch (_currentIndex) {
      case 1: // Workspaces
        return FloatingActionButton(
          onPressed: _showCreateWorkspaceDialog,
          child: const Icon(Icons.add_business),
        ).animate().scale(duration: 300.ms);
      case 2: // Projects
        return FloatingActionButton(
          onPressed: _showCreateProjectDialog,
          child: const Icon(Icons.add_box),
        ).animate().scale(duration: 300.ms);
      case 3: // Tasks
        return FloatingActionButton(
          onPressed: _showCreateTaskMessage,
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
      bottomNavigationBar: EnhancedBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}