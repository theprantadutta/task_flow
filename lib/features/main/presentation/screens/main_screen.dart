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
import 'package:task_flow/shared/widgets/bottom_sheet_wrapper.dart';
import 'package:task_flow/shared/widgets/enhanced_bottom_navigation_bar.dart';
// Page transitions will be used in future implementations

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ValueNotifier<bool> _refreshTasks = ValueNotifier<bool>(false);

  void onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        
        // If we're switching to the tasks screen, trigger a refresh
        if (_currentIndex == 3) {
          _refreshTasks.value = !_refreshTasks.value;
        }
      });
    }
  }

  Future<void> _showCreateWorkspaceBottomSheet() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext bottomSheetContext) {
          return BottomSheetWrapper(
            title: 'Create Workspace',
            content: CreateWorkspaceForm(
              ownerId: user.uid,
              onCreate: (workspace) async {
                try {
                  final workspaceService = WorkspaceService();
                  await workspaceService.createWorkspace(
                    name: workspace.name,
                    ownerId: user.uid,
                  );

                  if (bottomSheetContext.mounted) {
                    Navigator.pop(bottomSheetContext); // Close the bottom sheet

                    ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
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
                  if (bottomSheetContext.mounted) {
                    ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create workspace: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            onCreate: () {
              // The form will handle submission
            },
          );
        },
      );
    }
  }

  Future<void> _showCreateProjectBottomSheet() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    try {
      final workspaceService = WorkspaceService();
      final workspaces = await workspaceService.getUserWorkspaces(user.uid);

      if (workspaces.isEmpty) {
        if (mounted) {
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

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext bottomSheetContext) {
            return StatefulBuilder(
              builder: (context, setState) {
                return BottomSheetWrapper(
                  title: 'Create Project',
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

                            if (bottomSheetContext.mounted) {
                              Navigator.pop(bottomSheetContext); // Close the bottom sheet

                              ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Project created successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (bottomSheetContext.mounted) {
                              ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
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
                  onCreate: () {
                    // The form will handle submission
                  },
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
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
    if (mounted) {
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
          onPressed: _showCreateWorkspaceBottomSheet,
          child: const Icon(Icons.add_business),
        ).animate().scale(duration: 300.ms);
      case 2: // Projects
        return FloatingActionButton(
          onPressed: _showCreateProjectBottomSheet,
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
    // Create widgets with proper callbacks
    final Widget projectsScreen = ProjectsScreen(
      onTaskCreated: () {
        // When a task is created in a project, mark that we need to refresh tasks
        _refreshTasks.value = !_refreshTasks.value;
        
        // Show a message that the task was created
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );

    final Widget tasksScreen = ValueListenableBuilder<bool>(
      valueListenable: _refreshTasks,
      builder: (context, refresh, child) {
        return TasksScreen(
          key: ValueKey(refresh), // This will force a rebuild when refresh changes
          onTaskCreated: () {
            // When a task is created directly in the tasks screen
            _refreshTasks.value = !_refreshTasks.value;
          },
        );
      },
    );

    // Create a new list with the updated screens
    final List<Widget> children = [
      const DashboardScreen(),
      const WorkspaceListScreen(),
      projectsScreen,
      tasksScreen,
      const ProfileScreen(),
    ];

    return Scaffold(
      body: children[_currentIndex],
      bottomNavigationBar: EnhancedBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}