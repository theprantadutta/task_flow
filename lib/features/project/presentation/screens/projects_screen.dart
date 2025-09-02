import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/project/presentation/screens/project_list_screen.dart';
import 'package:task_flow/features/project/widgets/create_project_form.dart';
import 'package:task_flow/features/project/widgets/project_grid.dart';
import 'package:task_flow/shared/models/project.dart';
import 'package:task_flow/shared/services/project_service.dart';
import 'package:task_flow/shared/services/workspace_service.dart';
import 'package:task_flow/shared/widgets/bottom_sheet_wrapper.dart';

class ProjectsScreen extends StatefulWidget {
  final VoidCallback? onTaskCreated; // Add callback parameter

  const ProjectsScreen({super.key, this.onTaskCreated});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  late ProjectService _projectService;
  late WorkspaceService _workspaceService;
  List<Project> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _projectService = ProjectService();
    _workspaceService = WorkspaceService();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        // Get user's workspaces first
        final workspaces = await _workspaceService.getUserWorkspaces(user.uid);

        // Get projects for each workspace
        final allProjects = <Project>[];
        for (final workspace in workspaces) {
          final projects = await _projectService.getWorkspaceProjects(
            workspace.id,
          );
          allProjects.addAll(projects);
        }

        if (mounted) {
          setState(() {
            _projects = allProjects;
            _isLoading = false;
          });
        }
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

  Future<void> _showCreateProjectBottomSheet() async {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    try {
      final workspaces = await _workspaceService.getUserWorkspaces(user.uid);

      if (workspaces.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please create a workspace first'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      String? selectedWorkspaceId = workspaces.isNotEmpty
          ? workspaces.first.id
          : null;

      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext bottomSheetContext) {
            return StatefulBuilder(
              builder: (context, setState) {
                return BottomSheetWrapper(
                  title: 'Create Project',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedWorkspaceId,
                        items: workspaces.map((workspace) {
                          return DropdownMenuItem(
                            value: workspace.id,
                            child: Text(workspace.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedWorkspaceId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Workspace',
                        ),
                      ),
                      const SizedBox(height: 16),
                      CreateProjectForm(
                        workspaceId: selectedWorkspaceId ?? '',
                        ownerId: user.uid,
                        onCreate: (project) async {
                          if (selectedWorkspaceId == null) return;

                          try {
                            final newProject = await _projectService
                                .createProject(
                                  workspaceId: selectedWorkspaceId!,
                                  name: project.name,
                                  description: project.description,
                                  ownerId: user.uid,
                                );

                            if (mounted) {
                              setState(() {
                                _projects.add(newProject);
                              });

                              Navigator.pop(bottomSheetContext); // Close the bottom sheet

                              ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Project created successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (bottomSheetContext.mounted) {
                              ScaffoldMessenger.of(bottomSheetContext).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to create project: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  onCreate: () {
                    // The form will handle submission
                  },
                );
              },
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load workspaces: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditProjectDialog(Project project) {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: CreateProjectForm(
                workspaceId: project.workspaceId,
                ownerId: project.ownerId,
                onCreate: (updatedProject) async {
                  try {
                    final projectToUpdate = Project(
                      id: project.id,
                      workspaceId: project.workspaceId,
                      name: updatedProject.name,
                      description: updatedProject.description,
                      ownerId: project.ownerId,
                      createdAt: project.createdAt,
                    );
                    
                    await _projectService.updateProject(projectToUpdate);
                    
                    if (mounted) {
                      setState(() {
                        final index = _projects.indexWhere((p) => p.id == project.id);
                        if (index != -1) {
                          _projects[index] = projectToUpdate;
                        }
                      });

                      Navigator.pop(dialogContext); // Close the dialog

                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Project updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update project: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
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

  Future<void> _deleteProject(String projectId) async {
    try {
      // Find the project to get workspace ID
      final project = _projects.firstWhere((p) => p.id == projectId);
      
      await _projectService.deleteProject(project.workspaceId, projectId);
      
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProjectGrid(
              projects: _projects,
              onProjectTap: (project) {
                // Navigate to project detail/Kanban board screen
                // Find the workspace ID for this project
                final workspaceId = project.workspaceId;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProjectListScreen(workspaceId: workspaceId, onTaskCreated: widget.onTaskCreated), // Pass callback
                  ),
                );
              },
              onProjectEdit: _showEditProjectDialog,
              onProjectDelete: _showDeleteConfirmationDialog,
              onCreateProject: _showCreateProjectBottomSheet,
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Create Project',
        heroTag: 'createProject',
        onPressed: _showCreateProjectBottomSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}