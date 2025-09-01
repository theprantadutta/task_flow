import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ViewToggle extends StatelessWidget {
  final bool isListView;
  final Function(bool) onViewChanged;

  const ViewToggle({
    super.key,
    required this.isListView,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            icon: Icons.list,
            isSelected: isListView,
            onTap: () => onViewChanged(true),
          ),
          _buildToggleButton(
            context,
            icon: Icons.view_week,
            isSelected: !isListView,
            onTap: () => onViewChanged(false),
          ),
        ],
      ),
    ).animate().scale(duration: 300.ms);
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors.white
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
      ),
    );
  }
}