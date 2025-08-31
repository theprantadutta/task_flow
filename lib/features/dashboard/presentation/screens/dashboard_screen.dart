import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/dashboard/services/dashboard_service.dart';
import 'package:task_flow/features/project/widgets/create_project_form.dart';
import 'package:task_flow/features/workspace/widgets/create_workspace_form.dart';
import 'package:task_flow/shared/models/workspace.dart';
import 'package:task_flow/shared/services/project_service.dart';
import 'package:task_flow/shared/services/workspace_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardService _dashboardService;
  Map<String, dynamic> _userStats = {};
  List<dynamic> _workspaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardService();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = context.read<AuthBloc>().state.user;
      if (user != null) {
        final stats = await _dashboardService.getUserStats(user.uid);
        final workspaces = await _dashboardService.getUserWorkspaces(user.uid);

        if (mounted) {
          setState(() {
            _userStats = stats;
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    const DashboardHeader(),
                    const SizedBox(height: 24),

                    // Quick Stats
                    QuickStatsSection(
                      tasksCompleted: _userStats['tasksCompletedThisWeek'] ?? 0,
                      upcomingDeadlines: _userStats['upcomingDeadlines'] ?? 0,
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const QuickActionsSection(),
                    const SizedBox(height: 24),

                    // Workspace Overview
                    WorkspaceOverviewSection(workspaces: _workspaces),
                    const SizedBox(height: 24),

                    // Task Summary
                    const TaskSummarySection(),
                  ],
                ),
              ),
            ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state.user?.displayName ?? 'User';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning,',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 4),
            Text(
              userName,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here\'s what\'s happening with your tasks today',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}

class QuickStatsSection extends StatelessWidget {
  final int tasksCompleted;
  final int upcomingDeadlines;

  const QuickStatsSection({
    super.key,
    required this.tasksCompleted,
    required this.upcomingDeadlines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Tasks Completed',
            value: tasksCompleted.toString(),
            subtitle: 'This week',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Upcoming Deadlines',
            value: upcomingDeadlines.toString(),
            subtitle: 'Within 7 days',
            icon: Icons.calendar_today,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                title: 'Create Workspace',
                icon: Icons.add_business,
                onTap: () {
                  // Show create workspace dialog
                  final user = context.read<AuthBloc>().state.user;
                  if (user != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Create Workspace'),
                          content: CreateWorkspaceForm(
                            ownerId: user.uid,
                            onCreate: (workspace) async {
                              try {
                                final workspaceService = WorkspaceService();
                                await workspaceService.createWorkspace(
                                  name: workspace.name,
                                  ownerId: user.uid,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context); // Close the dialog

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Workspace created successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to create workspace: $e',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                title: 'Create Project',
                icon: Icons.add_box,
                onTap: () async {
                  // Show workspace selection dialog first, then create project
                  final user = context.read<AuthBloc>().state.user;
                  if (user != null) {
                    try {
                      final workspaceService = WorkspaceService();
                      final workspaces = await workspaceService
                          .getUserWorkspaces(user.uid);

                      if (workspaces.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please create a workspace first'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                        return;
                      }

                      if (context.mounted) {
                        _showCreateProjectDialog(context, user.uid, workspaces);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to load workspaces: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                context,
                title: 'Add Task',
                icon: Icons.add_task,
                onTap: () {
                  // Show message that task creation is done in project context
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tasks are created within projects'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreateProjectDialog(
    BuildContext context,
    String ownerId,
    List<Workspace> workspaces,
  ) {
    String? selectedWorkspaceId = workspaces.isNotEmpty
        ? workspaces.first.id
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Project'),
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
                    decoration: const InputDecoration(labelText: 'Workspace'),
                  ),
                  const SizedBox(height: 16),
                  CreateProjectForm(
                    workspaceId: selectedWorkspaceId ?? '',
                    ownerId: ownerId,
                    onCreate: (project) async {
                      if (selectedWorkspaceId == null) return;

                      try {
                        final projectService = ProjectService();
                        await projectService.createProject(
                          workspaceId: selectedWorkspaceId!,
                          name: project.name,
                          description: project.description,
                          ownerId: ownerId,
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Close the dialog

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Project created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
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
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkspaceOverviewSection extends StatelessWidget {
  final List<dynamic> workspaces;

  const WorkspaceOverviewSection({super.key, required this.workspaces});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Workspaces',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (workspaces.isEmpty)
          const SizedBox(
            height: 150,
            child: Center(child: Text('No workspaces yet')),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: workspaces.length,
              itemBuilder: (context, index) {
                final workspace = workspaces[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          workspace.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '0 projects',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class TaskSummarySection extends StatelessWidget {
  const TaskSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Task Summary',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // TODO: Replace with actual task summary data
        const SizedBox(
          height: 150,
          child: Center(child: Text('Task summary will appear here')),
        ),
      ],
    );
  }
}
