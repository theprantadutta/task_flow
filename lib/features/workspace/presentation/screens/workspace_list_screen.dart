import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/workspace/widgets/workspace_list.dart';
import 'package:task_flow/features/workspace/widgets/create_workspace_form.dart';
import 'package:task_flow/shared/services/workspace_service.dart';
import 'package:task_flow/shared/models/workspace.dart';

class WorkspaceListScreen extends StatefulWidget {
  const WorkspaceListScreen({super.key});

  @override
  State<WorkspaceListScreen> createState() => _WorkspaceListScreenState();
}

class _WorkspaceListScreenState extends State<WorkspaceListScreen> {
  late WorkspaceService _workspaceService;
  List<Workspace> _workspaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _workspaceService = WorkspaceService();
    _loadWorkspaces();
  }

  Future<void> _loadWorkspaces() async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        final workspaces = await _workspaceService.getUserWorkspaces(user.uid);
        if (mounted) {
          setState(() {
            _workspaces = workspaces;
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
            content: Text('Failed to load workspaces: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createWorkspace(Workspace workspace) async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        final newWorkspace = await _workspaceService.createWorkspace(
          name: workspace.name,
          ownerId: user.uid,
        );
        
        if (mounted) {
          setState(() {
            _workspaces.add(newWorkspace);
          });
          
          Navigator.pop(context); // Close the dialog
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workspace created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create workspace: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateWorkspaceDialog() {
    final user = context.read<AuthBloc>().state.user;
    if (user == null) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: CreateWorkspaceForm(
            ownerId: user.uid,
            onCreate: _createWorkspace,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspaces'),
        actions: [
          IconButton(
            onPressed: _showCreateWorkspaceDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : WorkspaceList(
              workspaces: _workspaces,
              onWorkspaceTap: (workspace) {
                // Navigate to workspace detail screen
              },
              onCreateWorkspace: _showCreateWorkspaceDialog,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateWorkspaceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}