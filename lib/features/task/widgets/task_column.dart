import 'package:flutter/material.dart';
import 'package:task_flow/shared/models/task.dart';
import 'package:task_flow/features/task/widgets/task_card.dart';

class TaskColumn extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  final String status;
  final Function(Task, String) onTaskStatusChanged;

  const TaskColumn({
    super.key,
    required this.title,
    required this.tasks,
    required this.status,
    required this.onTaskStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: DragTarget<Task>(
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                );
              },
              onAcceptWithDetails: (details) {
                // Handle task drop and update status
                onTaskStatusChanged(details.data, status);
              },
            ),
          ),
        ],
      ),
    );
  }
}