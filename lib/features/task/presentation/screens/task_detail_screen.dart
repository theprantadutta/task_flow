import 'package:flutter/material.dart';
import 'package:task_flow/shared/models/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement edit functionality
            },
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
                      task.title,
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
                      color: _getPriorityColor(task.priority),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      task.priority,
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
              if (task.description != null) ...[
                Text(
                  task.description!,
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
                        value: _formatDate(task.createdAt),
                      ),
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        context,
                        icon: Icons.update,
                        label: 'Last Updated',
                        value: _formatDate(task.updatedAt),
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 8),
                        _buildMetadataRow(
                          context,
                          icon: Icons.event,
                          label: 'Due Date',
                          value: _formatDate(task.dueDate!),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        context,
                        icon: Icons.flag,
                        label: 'Status',
                        value: task.status,
                      ),
                      const SizedBox(height: 8),
                      _buildMetadataRow(
                        context,
                        icon: Icons.person,
                        label: 'Reporter',
                        value: task.reporterId, // TODO: Replace with actual user name
                      ),
                      if (task.assigneeId != null) ...[
                        const SizedBox(height: 8),
                        _buildMetadataRow(
                          context,
                          icon: Icons.assignment_ind,
                          label: 'Assignee',
                          value: task.assigneeId!, // TODO: Replace with actual user name
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
}