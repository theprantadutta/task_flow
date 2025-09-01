import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/task/widgets/create_task_form.dart';
import 'package:task_flow/features/task/widgets/kanban_board.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/shared/services/task_service.dart';

class KanbanBoardScreen extends StatefulWidget {
  final String workspaceId;
  final String projectId;
  final String projectName;
  final VoidCallback? onTaskCreated;

  const KanbanBoardScreen({
    super.key,
    required this.workspaceId,
    required this.projectId,
    required this.projectName,
    this.onTaskCreated,
  });

  @override
  State<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  late TaskService _taskService;
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _taskService.getProjectTasks(
        widget.workspaceId,
        widget.projectId,
      );
      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
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

  void _onTaskStatusChanged(Task task, String newStatus) async {
    try {
      await _taskService.updateTaskStatus(
        widget.workspaceId,
        widget.projectId,
        task.id,
        newStatus,
      );

      if (mounted) {
        // Reload tasks to reflect the change
        _loadTasks();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task status updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateTaskDialog() {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create Task'),
          content: SingleChildScrollView(
            child: CreateTaskForm(
              projectId: widget.projectId,
              reporterId: user.uid,
              onCreate: (task) async {
                try {
                  final newTask = await _taskService.createTask(
                    workspaceId: widget.workspaceId,
                    projectId: widget.projectId,
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
                      _tasks.add(newTask);
                    });

                    Navigator.pop(dialogContext); // Close the dialog

                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Task created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Reload tasks to ensure consistency
                    _loadTasks();
                    
                    // Notify that a task was created
                    if (widget.onTaskCreated != null) {
                      widget.onTaskCreated!();
                    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(
            onPressed: _showCreateTaskDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : KanbanBoard(
              tasks: _tasks,
              onTaskTap: (task) {
                // TODO: Implement task tap
              },
              onTaskEdit: (task) {
                // TODO: Implement task edit
              },
              onTaskDelete: (task) {
                // TODO: Implement task delete
              },
              onTaskStatusChanged: _onTaskStatusChanged,
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new task',
        heroTag: 'addTask',
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}