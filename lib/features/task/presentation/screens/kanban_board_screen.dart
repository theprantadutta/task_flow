import 'package:flutter/material.dart';
import 'package:task_flow/features/task/widgets/kanban_board.dart';
import 'package:task_flow/shared/services/task_service.dart';
import 'package:task_flow/shared/models/task.dart';

class KanbanBoardScreen extends StatefulWidget {
  final String workspaceId;
  final String projectId;
  final String projectName;

  const KanbanBoardScreen({
    super.key,
    required this.workspaceId,
    required this.projectId,
    required this.projectName,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        actions: [
          IconButton(
            onPressed: () {
              // Add new task
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : KanbanBoard(
              tasks: _tasks,
              onTaskStatusChanged: _onTaskStatusChanged,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}