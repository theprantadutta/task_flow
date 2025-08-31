import 'package:flutter/material.dart';
import 'package:task_flow/features/project/presentation/screens/project_list_screen.dart';
import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/shared/services/workspace_service.dart';
import 'package:task_flow/features/workspace/widgets/create_workspace_form.dart';

class WorkspaceDetailScreen extends StatefulWidget {
  final Workspace workspace;

  const WorkspaceDetailScreen({super.key, required this.workspace});

  @override
  State<WorkspaceDetailScreen> createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  late WorkspaceService _workspaceService;
  Workspace? _workspace;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _workspaceService = WorkspaceService();
    _loadWorkspace();
  }

  Future<void> _loadWorkspace() async {
    try {
      final workspace = await _workspaceService.getWorkspace(widget.workspace.id);
      if (mounted) {
        setState(() {
          _workspace = workspace;
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
            content: Text('Failed to load workspace: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateWorkspace(Workspace updatedWorkspace) async {
    try {
      await _workspaceService.updateWorkspace(updatedWorkspace);
      if (mounted) {
        setState(() {
          _workspace = updatedWorkspace;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workspace updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update workspace: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditWorkspaceDialog() {
    if (_workspace == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Workspace'),
          content: CreateWorkspaceForm(
            ownerId: _workspace!.ownerId,
            onCreate: (workspace) async {
              final updatedWorkspace = Workspace(
                id: _workspace!.id,
                name: workspace.name,
                ownerId: _workspace!.ownerId,
                createdAt: _workspace!.createdAt,
              );
              await _updateWorkspace(updatedWorkspace);
              if (context.mounted) {
                Navigator.pop(context); // Close the dialog
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_workspace?.name ?? 'Workspace'),
        actions: [
          IconButton(
            onPressed: _showEditWorkspaceDialog,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workspace == null
              ? const Center(child: Text('Workspace not found'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Workspace info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _workspace!.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Created: ${_workspace!.createdAt.toString().split(' ')[0]}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 4),
                                  const Text('Owner'),
                                  const SizedBox(width: 8),
                                  // TODO: Fetch and display owner name
                                  const Text('You'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Projects section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Projects',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProjectListScreen(
                                          workspaceId: _workspace!.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View All Projects'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ProjectListScreen(
                                workspaceId: _workspace!.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}