import 'package:flutter/material.dart';
import 'package:task_flow/shared/models/workspace.dart';

class EnhancedWorkspaceCard extends StatelessWidget {
  final Workspace workspace;
  final VoidCallback onTap;
  final Color color;

  const EnhancedWorkspaceCard({
    super.key,
    required this.workspace,
    required this.onTap,
    this.color = Colors.deepPurple,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color header
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  Icons.work,
                  size: 30,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workspace.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 4),
                  const SizedBox(height: 8),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Icons.folder, '0'), // TODO: Replace with actual project count
                      _buildStatItem(Icons.people, '1'), // TODO: Replace with actual member count
                      _buildStatItem(Icons.access_time, 'Today'), // TODO: Replace with actual last activity
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}