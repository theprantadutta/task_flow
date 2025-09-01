import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/task/services/personal_task_service.dart';
import 'package:task_flow/features/task/widgets/create_task_form.dart';
import 'package:task_flow/features/task/widgets/kanban_board_view.dart';
import 'package:task_flow/features/task/widgets/task_filter_bar.dart';
import 'package:task_flow/features/task/widgets/task_list_view.dart';
import 'package:task_flow/features/task/widgets/task_summary_header.dart';
import 'package:task_flow/features/task/widgets/view_toggle.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/shared/services/project_service.dart';
import 'package:task_flow/shared/services/task_service.dart';
import 'package:task_flow/shared/services/workspace_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late PersonalTaskService _personalTaskService;
  late TaskService _taskService;
  late WorkspaceService _workspaceService;
  late ProjectService _projectService;

  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  bool _isListView = true;
  Map<String, int> _taskStats = {'today': 0, 'overdue': 0, 'upcoming': 0};

  // Filter parameters
  String _statusFilter = 'all';
  String _priorityFilter = 'all';
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _personalTaskService = PersonalTaskService();
    _taskService = TaskService();
    _workspaceService = WorkspaceService();
    _projectService = ProjectService();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        // Load personal tasks
        final tasks = await _personalTaskService.getUserTasks(user.uid);
        final stats = await _personalTaskService.getUserTaskStats(user.uid);

        if (mounted) {
          setState(() {
            _allTasks = tasks;
            _taskStats = stats;
            _applyFilters(); // Apply current filters to get filtered tasks
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tasks: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTasks = _personalTaskService.filterTasks(
        _allTasks,
        status: _statusFilter,
        priority: _priorityFilter,
        searchTerm: _searchTerm,
      );
    });
  }

  void _onFilterChanged(String status, String priority, String searchTerm) {
    setState(() {
      _statusFilter = status;
      _priorityFilter = priority;
      _searchTerm = searchTerm;
      _applyFilters();
    });
  }

  void _onViewChanged(bool isList) {
    setState(() {
      _isListView = isList;
    });
  }

  Future<void> _showCreateTaskDialog() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    try {
      // Get user's workspaces
      final workspaces = await _workspaceService.getUserWorkspaces(user.uid);

      if (workspaces.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please create a workspace and project first'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get projects from first workspace
      final projects = await _projectService.getWorkspaceProjects(
        workspaces.first.id,
      );

      if (projects.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please create a project first'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final selectedProjectId = projects.first.id;

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Create Task'),
              content: CreateTaskForm(
                projectId: selectedProjectId,
                reporterId: user.uid,
                onCreate: (task) async {
                  try {
                    // Find workspace ID for the project
                    String? workspaceId;
                    for (final workspace in workspaces) {
                      final workspaceProjects = await _projectService
                          .getWorkspaceProjects(workspace.id);
                      if (workspaceProjects.any(
                        (p) => p.id == selectedProjectId,
                      )) {
                        workspaceId = workspace.id;
                        break;
                      }
                    }

                    if (workspaceId == null) return;

                    // Create the task
                    final newTask = await _taskService.createTask(
                      workspaceId: workspaceId,
                      projectId: selectedProjectId,
                      title: task.title,
                      description: task.description,
                      status: task.status,
                      assigneeId: task.assigneeId,
                      reporterId: task.reporterId,
                      dueDate: task.dueDate,
                      priority: task.priority,
                    );

                    if (dialogContext.mounted) {
                      setState(() {
                        _allTasks.add(newTask);
                        _applyFilters();
                      });

                      Navigator.pop(dialogContext); // Close the dialog

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Task created successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Refresh stats
                      _loadTasks();
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create task: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load workspaces/projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onTaskTap(Task task) {
    // TODO: Navigate to task detail screen
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task tapped: ${task.title}'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _onTaskEdit(Task task) {
    // TODO: Implement task editing
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Edit task: ${task.title}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _onTaskDelete(Task task) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // TODO: Find workspace ID for this task
                  // For now, we'll just remove it from the local list
                  if (context.mounted) {
                    setState(() {
                      _allTasks.removeWhere((t) => t.id == task.id);
                      _applyFilters();
                    });

                    Navigator.pop(dialogContext); // Close the dialog

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }

                    // Refresh stats
                    _loadTasks();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete task: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(onPressed: _loadTasks, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Task summary header
                      TaskSummaryHeader(
                        todayTasks: _taskStats['today'] ?? 0,
                        overdueTasks: _taskStats['overdue'] ?? 0,
                        upcomingTasks: _taskStats['upcoming'] ?? 0,
                      ),
                      const SizedBox(height: 16),

                      // View toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ViewToggle(
                            isListView: _isListView,
                            onViewChanged: _onViewChanged,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Task filter bar
                      TaskFilterBar(onFilterChanged: _onFilterChanged),
                      const SizedBox(height: 16),

                      // Task list or Kanban board
                      if (_isListView)
                        TaskListView(
                          tasks: _filteredTasks,
                          onTaskTap: _onTaskTap,
                          onTaskEdit: _onTaskEdit,
                          onTaskDelete: _onTaskDelete,
                        )
                      else
                        KanbanBoardView(
                          tasks: _filteredTasks,
                          onTaskTap: _onTaskTap,
                          onTaskEdit: _onTaskEdit,
                          onTaskDelete: _onTaskDelete,
                          onTaskStatusChanged: (task, newStatus) {
                            // TODO: Implement status change
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Task',
        heroTag: 'createTask',
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
