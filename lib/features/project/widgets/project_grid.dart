import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_flow/shared/models/project.dart';
import 'package:task_flow/features/project/widgets/project_card_enhanced.dart';

class ProjectGrid extends StatelessWidget {
  final List<Project> projects;
  final Function(Project) onProjectTap;
  final Function(Project) onProjectEdit;
  final Function(Project) onProjectDelete;
  final VoidCallback onCreateProject;

  const ProjectGrid({
    super.key,
    required this.projects,
    required this.onProjectTap,
    required this.onProjectEdit,
    required this.onProjectDelete,
    required this.onCreateProject,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first project to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCreateProject,
              child: const Text('Create Project'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return EnhancedProjectCard(
          project: project,
          onTap: () => onProjectTap(project),
          onEdit: () => onProjectEdit(project),
          onDelete: () => onProjectDelete(project),
          progress: _getProjectProgress(index), // TODO: Replace with actual progress calculation
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, duration: 300.ms);
      },
    );
  }

  double _getProjectProgress(int index) {
    // Simulate different progress values for demo
    final progressValues = [0.5, 0.8, 0.2, 0.9, 0.1, 0.7];
    return progressValues[index % progressValues.length];
  }
}