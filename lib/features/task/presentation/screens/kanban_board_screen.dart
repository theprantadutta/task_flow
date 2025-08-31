import 'package:flutter/material.dart';

class KanbanBoardScreen extends StatelessWidget {
  const KanbanBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
        actions: [
          IconButton(
            onPressed: () {
              // Add new task
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: const Center(
        child: Text('Your Kanban board will appear here'),
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