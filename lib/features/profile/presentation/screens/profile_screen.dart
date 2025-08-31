import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/features/auth/bloc/auth_bloc.dart';
import 'package:task_flow/features/profile/widgets/profile_header.dart';
import 'package:task_flow/features/profile/widgets/profile_form.dart';
import 'package:task_flow/shared/services/user_service.dart';

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
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
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
}