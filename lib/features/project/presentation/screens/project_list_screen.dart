import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/project/widgets/project_list.dart';
import 'package:task_flow/features/project/widgets/create_project_form.dart';
import 'package:task_flow/shared/services/project_service.dart';
import 'package:task_flow/shared/models/project.dart';

class ProjectListScreen extends StatefulWidget {
  final String workspaceId;

  const ProjectListScreen({super.key, required this.workspaceId});

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
      final projects = await _projectService.getWorkspaceProjects(widget.workspaceId);
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
                    ),
                  ),
                );
              },
              onCreateProject: _showCreateProjectDialog,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}