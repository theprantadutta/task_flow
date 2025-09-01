import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/project/widgets/create_project_form.dart';
import 'package:task_flow/features/project/widgets/project_list.dart';
import 'package:task_flow/features/task/presentation/screens/kanban_board_screen.dart';
import 'package:task_flow/shared/models/project.dart';
import 'package:task_flow/shared/services/project_service.dart';

class ProjectListScreen extends StatefulWidget {
  final String workspaceId;
  final VoidCallback? onTaskCreated; // Add this callback parameter

  const ProjectListScreen({super.key, required this.workspaceId, this.onTaskCreated});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late ProjectService _projectService;
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _projectService = ProjectService();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _projectService.getWorkspaceProjects(
        widget.workspaceId,
      );
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createProject(Project project) async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        final newProject = await _projectService.createProject(
          workspaceId: widget.workspaceId,
          name: project.name,
          description: project.description,
          ownerId: user.uid,
        );

        if (mounted) {
          setState(() {
            _projects.add(newProject);
          });

          Navigator.pop(context); // Close the dialog

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProject(Project updatedProject) async {
    try {
      await _projectService.updateProject(updatedProject);
      if (mounted) {
        setState(() {
          final index = _projects.indexWhere((p) => p.id == updatedProject.id);
          if (index != -1) {
            _projects[index] = updatedProject;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(String projectId) async {
    try {
      await _projectService.deleteProject(widget.workspaceId, projectId);
      if (mounted) {
        setState(() {
          _projects.removeWhere((p) => p.id == projectId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateProjectDialog() {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: CreateProjectForm(
            workspaceId: widget.workspaceId,
            ownerId: user.uid,
            onCreate: _createProject,
          ),
        );
      },
    );
  }

  void _showEditProjectDialog(Project project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: CreateProjectForm(
            workspaceId: widget.workspaceId,
            ownerId: project.ownerId,
            onCreate: (updatedProject) async {
              final projectToUpdate = Project(
                id: project.id,
                workspaceId: project.workspaceId,
                name: updatedProject.name,
                description: updatedProject.description,
                ownerId: project.ownerId,
                createdAt: project.createdAt,
              );
              await _updateProject(projectToUpdate);
              if (context.mounted) {
                Navigator.pop(context); // Close the dialog
              }
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Project project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text('Are you sure you want to delete "${project.name}"? This action cannot be undone and will delete all tasks in this project.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                await _deleteProject(project.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            onPressed: _showCreateProjectDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProjectList(
              projects: _projects,
              onProjectTap: (project) {
                // Navigate to project detail/Kanban board screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KanbanBoardScreen(
                      workspaceId: widget.workspaceId,
                      projectId: project.id,
                      projectName: project.name,
                      onTaskCreated: widget.onTaskCreated, // Pass the callback through
                    ),
                  ),
                );
              },
              onProjectEdit: _showEditProjectDialog,
              onProjectDelete: _showDeleteConfirmationDialog,
              onCreateProject: _showCreateProjectDialog,
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Project',
        heroTag: 'createProjectButton',
        onPressed: _showCreateProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}