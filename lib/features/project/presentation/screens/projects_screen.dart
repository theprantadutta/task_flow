import 'package:flutter/material.dart';
import 'package:task_flow/features/project/widgets/project_grid.dart';
import 'package:task_flow/shared/models/project.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement filter
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
        ),
      ),
      body: ProjectGrid(
        projects: [
          // TODO: Replace with actual project data
          Project(id: '1', workspaceId: '1', name: 'Project 1', ownerId: '1', createdAt: DateTime.now()),
          Project(id: '2', workspaceId: '1', name: 'Project 2', ownerId: '1', createdAt: DateTime.now()),
        ],
        onProjectTap: (project) {
          // TODO: Navigate to project detail
        },
        onCreateProject: () {
          // TODO: Implement create project
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create project
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}