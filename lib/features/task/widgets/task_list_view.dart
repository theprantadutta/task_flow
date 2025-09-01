import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_flow/features/task/widgets/enhanced_task_card.dart';
import 'package:task_flow/shared/models/task.dart';

class TaskListView extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskEdit;
  final Function(Task) onTaskDelete;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskEdit,
    required this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 64,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first task to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return EnhancedTaskCard(
          task: task,
          onTap: () => onTaskTap(task),
          onEdit: () => onTaskEdit(task),
          onDelete: () => onTaskDelete(task),
        ).animate().fadeIn(duration: 300.ms).slideX(
          begin: index % 2 == 0 ? -0.2 : 0.2,
          end: 0,
          duration: 300.ms,
        );
      },
    );
  }
}