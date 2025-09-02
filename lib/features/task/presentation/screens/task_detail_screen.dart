import 'package:flutter/material.dart';
import 'package:task_flow/features/task/widgets/edit_task_form.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/shared/services/task_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final String workspaceId;
  final Function(Task)? onTaskUpdated;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.workspaceId,
    this.onTaskUpdated,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _updateTask(Task updatedTask) async {
    try {
      final taskService = TaskService();
      await taskService.updateTask(updatedTask, widget.workspaceId);
      
      setState(() {
        _task = updatedTask;
      });
      
      if (widget.onTaskUpdated != null) {
        widget.onTaskUpdated!(updatedTask);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: EditTaskForm(
              task: _task,
              onSave: (updatedTask) async {
                await _updateTask(updatedTask);
                if (context.mounted) {
                  Navigator.pop(context); // Close the dialog
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: _showEditTaskDialog,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _task.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(_task.priority),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      _task.priority,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Task description
              if (_task.description != null) ...[
                Text(
                  _task.description!,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Task metadata
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildMetadataRow(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Created',
                        value: _formatDate(_task.createdAt),
                      ),
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        context,
                        icon: Icons.update,
                        label: 'Last Updated',
                        value: _formatDate(_task.updatedAt),
                      ),
                      if (_task.dueDate != null) ...[
                        const SizedBox(height: 8),
                        _buildMetadataRow(
                          context,
                          icon: Icons.event,
                          label: 'Due Date',
                          value: _formatDate(_task.dueDate!),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        context,
                        icon: Icons.flag,
                        label: 'Status',
                        value: _formatStatus(_task.status),
                      ),
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        context,
                        icon: Icons.person,
                        label: 'Reporter',
                        value: _task.reporterId, // TODO: Replace with actual user name
                      ),
                      if (_task.assigneeId != null) ...[
                        const SizedBox(height: 8),
                        _buildMetadataRow(
                          context,
                          icon: Icons.assignment_ind,
                          label: 'Assignee',
                          value: _task.assigneeId!, // TODO: Replace with actual user name
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Comments section
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: null, // TODO: Implement comment submission
                          child: const Text('Post Comment'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('No comments yet'),
              ),
              
              const SizedBox(height: 16),
              
              // Attachments section
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Center(
                        child: Text('No attachments'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: null, // TODO: Implement attachment upload
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Add Attachment'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      default:
        return status;
    }
  }
}