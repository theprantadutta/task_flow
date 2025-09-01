import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EnhancedBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const EnhancedBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.5) 
                : Colors.grey.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          selectedItemColor: isDarkMode 
              ? Colors.deepPurpleAccent // Better contrast for dark mode
              : Theme.of(context).primaryColor,
          unselectedItemColor: isDarkMode 
              ? Colors.grey[300] // Better visibility in dark mode
              : Colors.grey[600],
          currentIndex: currentIndex,
          onTap: onTap,
          elevation: 0,
          items: [
            _buildNavigationBarItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              index: 0,
              isDarkMode: isDarkMode,
            ),
            _buildNavigationBarItem(
              icon: Icons.work_outline,
              activeIcon: Icons.work,
              label: 'Workspaces',
              index: 1,
              isDarkMode: isDarkMode,
            ),
            _buildNavigationBarItem(
              icon: Icons.folder_open,
              activeIcon: Icons.folder,
              label: 'Projects',
              index: 2,
              isDarkMode: isDarkMode,
            ),
            _buildNavigationBarItem(
              icon: Icons.task_outlined,
              activeIcon: Icons.task,
              label: 'Tasks',
              index: 3,
              isDarkMode: isDarkMode,
            ),
            _buildNavigationBarItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              index: 4,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDarkMode,
  }) {
    final isSelected = currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: Icon(icon).animate().scale(
        duration: 200.ms,
        begin: const Offset(1, 1),
        end: isSelected ? const Offset(1.2, 1.2) : const Offset(1, 1),
        curve: Curves.easeInOut,
      ),
      activeIcon: Icon(activeIcon, size: 28).animate().scale(
        duration: 200.ms,
        begin: const Offset(1, 1),
        end: isSelected ? const Offset(1.2, 1.2) : const Offset(1, 1),
        curve: Curves.easeInOut,
      ),
      label: label,
    );
  }
}