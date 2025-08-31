import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement filter
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: const Center(
        child: Text('Tasks will be displayed here'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create task
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}