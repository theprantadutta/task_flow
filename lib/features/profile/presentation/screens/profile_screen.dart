import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/profile/widgets/profile_header.dart';
import 'package:task_flow/features/profile/widgets/profile_form.dart';
import 'package:task_flow/shared/services/user_service.dart';
import 'package:task_flow/core/themes/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.status == AuthStatus.authenticated && state.user != null) {
            if (_isEditing) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ProfileForm(
                  user: state.user!,
                  onSave: (updatedUser) async {
                    try {
                      // Update user in Firestore
                      final userService = UserService();
                      await userService.updateUser(updatedUser);
                      
                      // Check if context is still mounted
                      if (!context.mounted) return;
                      
                      // Update user in auth state
                      context.read<AuthBloc>().add(AuthUserUpdated(updatedUser));
                      
                      // Exit edit mode
                      setState(() {
                        _isEditing = false;
                      });
                      
                      // Show success message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      // Show error message
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to update profile: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ProfileHeader(user: state.user!),
                  const SizedBox(height: 32),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      // Navigate to settings
                      _showSettingsDialog(context);
                    },
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: const Text('Dark Mode'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    onTap: () {
                      // Handle notifications settings
                      _showNotificationsDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Privacy'),
                    onTap: () {
                      // Handle privacy settings
                      _showPrivacyDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    onTap: () {
                      // Handle help and support
                      _showHelpDialog(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About'),
                    onTap: () {
                      // Handle about
                      _showAboutDialog(context);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      // Logout
                      context.read<AuthBloc>().add(const AuthLoggedOut());
                    },
                  ),
                ],
              ),
            );
          }
          
          return const Center(child: Text('User not found'));
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: const Text('Settings options would be implemented here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifications'),
          content: const Text('Notification settings would be implemented here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Privacy'),
          content: const Text('Privacy settings would be implemented here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text('Help and support options would be implemented here.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About TaskFlow'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TaskFlow v1.0.0'),
              SizedBox(height: 16),
              Text('A productivity app to help you manage your tasks and projects efficiently.'),
              SizedBox(height: 16),
              Text('© 2025 TaskFlow. All rights reserved.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}