import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskSummaryHeader extends StatelessWidget {
  final int todayTasks;
  final int overdueTasks;
  final int upcomingTasks;

  const TaskSummaryHeader({
    super.key,
    required this.todayTasks,
    required this.overdueTasks,
    required this.upcomingTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              context,
              title: 'Today',
              count: todayTasks,
              icon: Icons.today,
              color: Colors.deepPurple,
            ),
            _buildStatItem(
              context,
              title: 'Overdue',
              count: overdueTasks,
              icon: Icons.warning,
              color: Colors.red,
            ),
            _buildStatItem(
              context,
              title: 'Upcoming',
              count: upcomingTasks,
              icon: Icons.calendar_today,
              color: Colors.green,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, duration: 500.ms);
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
        ),
      ],
    );
  }
}