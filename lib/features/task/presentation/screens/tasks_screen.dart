import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/task/presentation/screens/task_detail_screen.dart';
import 'package:task_flow/features/task/services/personal_task_service.dart';
import 'package:task_flow/features/task/widgets/create_task_form.dart';
import 'package:task_flow/features/task/widgets/kanban_board_view.dart';
import 'package:task_flow/features/task/widgets/task_filter_bar.dart';
import 'package:task_flow/features/task/widgets/task_list_view.dart';
import 'package:task_flow/features/task/widgets/task_summary_header.dart';
import 'package:task_flow/features/task/widgets/view_toggle.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/shared/models/project.dart';
import 'package:task_flow/shared/services/project_service.dart';
import 'package:task_flow/shared/services/task_service.dart';
import 'package:task_flow/shared/services/workspace_service.dart';
import 'package:task_flow/shared/widgets/bottom_sheet_wrapper.dart';

class TasksScreen extends StatefulWidget {
  final VoidCallback? onTaskCreated; // Add callback parameter

  const TasksScreen({super.key, this.onTaskCreated});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _personalTaskService = PersonalTaskService();
    _taskService = TaskService();
    _workspaceService = WorkspaceService();
    _projectService = ProjectService();
    _loadTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh tasks when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _loadTasks();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh tasks when the widget is rebuilt
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        // Load personal tasks (assigned tasks)
        final assignedTasks = await _personalTaskService.getUserTasks(user.uid);
        
        // Also get reported tasks as fallback
        final reportedTasks = await _personalTaskService.getUserReportedTasks(user.uid);
        
        // Combine both lists and remove duplicates
        final allTasksSet = <String, Task>{};
        for (final task in assignedTasks) {
          allTasksSet[task.id] = task;
        }
        for (final task in reportedTasks) {
          allTasksSet[task.id] = task;
        }
        
        final allTasks = allTasksSet.values.toList();
        
        final stats = await _personalTaskService.getUserTaskStats(user.uid);

        if (mounted) {
          setState(() {
            _allTasks = allTasks;
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

  Future<void> _showCreateTaskBottomSheet() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    try {
      // Get user's workspaces
      final workspaces = await _workspaceService.getUserWorkspaces(user.uid);

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

      // Let user select a workspace
      Workspace? selectedWorkspace;
      if (workspaces.length > 1) {
        selectedWorkspace = await _showWorkspaceSelectionDialog(workspaces);
      } else {
        selectedWorkspace = workspaces.first;
      }

      if (selectedWorkspace == null) return;

      // Get projects from selected workspace
      final projects = await _projectService.getWorkspaceProjects(
        selectedWorkspace.id,
      );

      if (projects.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please create a project first'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Let user select a project
      Project? selectedProject;
      if (projects.length > 1) {
        selectedProject = await _showProjectSelectionDialog(projects);
      } else {
        selectedProject = projects.first;
      }

      if (selectedProject == null) return;

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext bottomSheetContext) {
            return BottomSheetWrapper(
              title: 'Create Task',
              content: SingleChildScrollView(
                child: CreateTaskForm(
                  projectId: selectedProject!.id,
                  reporterId: user.uid,
                  onCreate: (task) async {
                    try {
                      // Create the task
                      final newTask = await _taskService.createTask(
                        workspaceId: selectedWorkspace!.id,
                        projectId: selectedProject!.id,
                        title: task.title,
                        description: task.description,
                        status: task.status,
                        assigneeId: task.assigneeId,
                        reporterId: task.reporterId,
                        dueDate: task.dueDate,
                        priority: task.priority,
                      );

                      if (bottomSheetContext.mounted) {
                        setState(() {
                          _allTasks.add(newTask);
                          _applyFilters();
                        });

                        Navigator.pop(bottomSheetContext); // Close the bottom sheet

                        ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                          const SnackBar(
                            content: Text('Task created successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Refresh stats
                        _loadTasks();
                        
                        // Notify that a task was created
                        if (widget.onTaskCreated != null) {
                          widget.onTaskCreated!();
                        }
                      }
                    } catch (e) {
                      if (bottomSheetContext.mounted) {
                        ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create task: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              onCreate: () {
                // The form will handle submission
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load workspaces/projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<Workspace?> _showWorkspaceSelectionDialog(List<Workspace> workspaces) async {
    return await showDialog<Workspace>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Workspace'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: workspaces.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(workspaces[index].name),
                  onTap: () {
                    Navigator.pop(context, workspaces[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<Project?> _showProjectSelectionDialog(List<Project> projects) async {
    return await showDialog<Project>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Project'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(projects[index].name),
                  onTap: () {
                    Navigator.pop(context, projects[index]);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onTaskTap(Task task) {
    // Find workspace ID for this task
    // We need to find the workspace that contains this task's project
    _navigateToTaskDetail(task);
  }

  void _onTaskEdit(Task task) {
    // Navigate to task detail screen for editing
    _navigateToTaskDetail(task);
  }

  void _onTaskDelete(Task task) {
    // TODO: Implement task deletion
  }

  void _onTaskStatusChanged(Task task, String newStatus) {
    // TODO: Implement task status change
  }

  Future<void> _navigateToTaskDetail(Task task) async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user == null) return;

      // Get user's workspaces
      final workspaces = await _workspaceService.getUserWorkspaces(user.uid);
      
      // Find the workspace that contains this task's project
      String workspaceId = ''; // Default to empty string
      for (final workspace in workspaces) {
        try {
          final project = await _projectService.getProject(
            workspace.id,
            task.projectId,
          );
          if (project != null) {
            workspaceId = workspace.id;
            break;
          }
        } catch (e) {
          // Continue to next workspace
        }
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(
              task: task,
              workspaceId: workspaceId, // Now always a String
              onTaskUpdated: (updatedTask) {
                setState(() {
                  final index = _allTasks.indexWhere((t) => t.id == updatedTask.id);
                  if (index != -1) {
                    _allTasks[index] = updatedTask;
                    _applyFilters();
                  }
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load workspace: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement sort functionality
            },
            icon: const Icon(Icons.sort),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: TaskFilterBar(
            onFilterChanged: _onFilterChanged,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: Column(
                children: [
                  TaskSummaryHeader(
                    todayTasks: _taskStats['today'] ?? 0,
                    overdueTasks: _taskStats['overdue'] ?? 0,
                    upcomingTasks: _taskStats['upcoming'] ?? 0,
                  ),
                  ViewToggle(
                    isListView: _isListView,
                    onViewChanged: _onViewChanged,
                  ),
                  Expanded(
                    child: _isListView
                        ? TaskListView(
                            tasks: _filteredTasks,
                            onTaskTap: _onTaskTap,
                            onTaskEdit: _onTaskEdit,
                            onTaskDelete: _onTaskDelete,
                          )
                        : KanbanBoardView(
                            tasks: _filteredTasks,
                            onTaskTap: _onTaskTap,
                            onTaskEdit: _onTaskEdit,
                            onTaskDelete: _onTaskDelete,
                            onTaskStatusChanged: _onTaskStatusChanged,
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateTaskBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}