import 'package:flutter/material.dart';
import 'package:task_flow/shared/models/project.dart';
import 'package:task_flow/features/project/widgets/project_card.dart';

class ProjectList extends StatelessWidget {
  final List<Project> projects;
  final Function(Project) onProjectTap;
  final Function() onCreateProject;

  const ProjectList({
    super.key,
    required this.projects,
    required this.onProjectTap,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Projects',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onCreateProject,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        if (projects.isEmpty) ...[
          const Expanded(
            child: Center(
              child: Text(
                'No projects yet. Create your first project!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectCard(
                  project: project,
                  onTap: () => onProjectTap(project),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}