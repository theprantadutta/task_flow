import 'package:flutter/material.dart';
import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/features/workspace/widgets/workspace_card.dart';

class WorkspaceList extends StatelessWidget {
  final List<Workspace> workspaces;
  final Function(Workspace) onWorkspaceTap;
  final Function() onCreateWorkspace;

  const WorkspaceList({
    super.key,
    required this.workspaces,
    required this.onWorkspaceTap,
    required this.onCreateWorkspace,
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
                'Workspaces',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onCreateWorkspace,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        if (workspaces.isEmpty) ...[
          const Expanded(
            child: Center(
              child: Text(
                'No workspaces yet. Create your first workspace!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ] else ...[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: workspaces.length,
              itemBuilder: (context, index) {
                final workspace = workspaces[index];
                return WorkspaceCard(
                  workspace: workspace,
                  onTap: () => onWorkspaceTap(workspace),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}