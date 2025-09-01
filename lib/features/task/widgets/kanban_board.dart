import 'package:flutter/material.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/features/task/widgets/task_column.dart';

class KanbanBoard extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;
  final Function(Task) onTaskEdit;
  final Function(Task) onTaskDelete;
  final Function(Task, String) onTaskStatusChanged;

  const KanbanBoard({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskEdit,
    required this.onTaskDelete,
    required this.onTaskStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Group tasks by status
    final todoTasks = tasks.where((task) => task.status == 'todo').toList();
    final inProgressTasks = tasks.where((task) => task.status == 'in_progress').toList();
    final doneTasks = tasks.where((task) => task.status == 'done').toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskColumn(
            title: 'To Do',
            tasks: todoTasks,
            status: 'todo',
            onTaskTap: onTaskTap,
            onTaskEdit: onTaskEdit,
            onTaskDelete: onTaskDelete,
            onTaskStatusChanged: onTaskStatusChanged,
          ),
          TaskColumn(
            title: 'In Progress',
            tasks: inProgressTasks,
            status: 'in_progress',
            onTaskTap: onTaskTap,
            onTaskEdit: onTaskEdit,
            onTaskDelete: onTaskDelete,
            onTaskStatusChanged: onTaskStatusChanged,
          ),
          TaskColumn(
            title: 'Done',
            tasks: doneTasks,
            status: 'done',
            onTaskTap: onTaskTap,
            onTaskEdit: onTaskEdit,
            onTaskDelete: onTaskDelete,
            onTaskStatusChanged: onTaskStatusChanged,
          ),
        ],
      ),
    );
  }
}