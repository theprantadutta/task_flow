import 'package:flutter/material.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/features/task/widgets/task_column.dart';

class KanbanBoard extends StatelessWidget {
  final List<Task> tasks;

  const KanbanBoard({super.key, required this.tasks});

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
          ),
          TaskColumn(
            title: 'In Progress',
            tasks: inProgressTasks,
            status: 'in_progress',
          ),
          TaskColumn(
            title: 'Done',
            tasks: doneTasks,
            status: 'done',
          ),
        ],
      ),
    );
  }
}