import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TaskFilterBar extends StatefulWidget {
  final Function(String, String, String)
  onFilterChanged; // status, priority, search

  const TaskFilterBar({super.key, required this.onFilterChanged});

  @override
  State<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends State<TaskFilterBar> {
  String _selectedStatus = 'all';
  String _selectedPriority = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _notifyFilterChanged();
  }

  void _notifyFilterChanged() {
    widget.onFilterChanged(
      _selectedStatus,
      _selectedPriority,
      _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
            const SizedBox(height: 16),

            // Filter chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: _selectedStatus == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 'all' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
                _buildFilterChip(
                  label: 'To Do',
                  isSelected: _selectedStatus == 'todo',
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 'todo' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
                _buildFilterChip(
                  label: 'In Progress',
                  isSelected: _selectedStatus == 'in_progress',
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 'in_progress' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
                _buildFilterChip(
                  label: 'Done',
                  isSelected: _selectedStatus == 'done',
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? 'done' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Priority filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterChip(
                  label: 'All Priority',
                  isSelected: _selectedPriority == 'all',
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? 'all' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
                _buildFilterChip(
                  label: 'High',
                  isSelected: _selectedPriority == 'high',
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? 'high' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
                _buildFilterChip(
                  label: 'Medium',
                  isSelected: _selectedPriority == 'medium',
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? 'medium' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
                _buildFilterChip(
                  label: 'Low',
                  isSelected: _selectedPriority == 'low',
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority = selected ? 'low' : '';
                    });
                    _notifyFilterChanged();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, duration: 500.ms);
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
      labelStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    );
  }
}
