import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/features/workspace/widgets/workspace_card_enhanced.dart';

class WorkspaceGrid extends StatelessWidget {
  final List<Workspace> workspaces;
  final Function(Workspace) onWorkspaceTap;
  final VoidCallback onCreateWorkspace;

  const WorkspaceGrid({
    super.key,
    required this.workspaces,
    required this.onWorkspaceTap,
    required this.onCreateWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    if (workspaces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.work_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No workspaces yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first workspace to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCreateWorkspace,
              child: const Text('Create Workspace'),
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
      itemCount: workspaces.length,
      itemBuilder: (context, index) {
        final workspace = workspaces[index];
        return EnhancedWorkspaceCard(
          workspace: workspace,
          onTap: () => onWorkspaceTap(workspace),
          color: _getColorForWorkspace(index),
        ).animate().fade(duration: 300.ms).slideY(begin: 0.2, duration: 300.ms);
      },
    );
  }

  Color _getColorForWorkspace(int index) {
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];
    return colors[index % colors.length];
  }
}