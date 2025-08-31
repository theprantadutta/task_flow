import 'package:task_flow/shared/models/user.dart';
import 'package:task_flow/shared/services/base_service.dart';
import 'package:task_flow/core/constants/app_constants.dart';
import 'package:task_flow/core/utils/logger.dart';

class UserService extends BaseService {
  Future<void> createUser(User user) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson());
      
      Logger.info('User created: ${user.uid}');
    } catch (e) {
      Logger.error('Error creating user: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String uid) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (snapshot.exists) {
        return User.fromJson(snapshot.data()!);
      }
      
      return null;
    } catch (e) {
      Logger.error('Error getting user: $e');
      rethrow;
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(user.toJson());
      
      Logger.info('User updated: ${user.uid}');
    } catch (e) {
      Logger.error('Error updating user: $e');
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(String uid, String imagePath) async {
    try {
      // In a real implementation, you would upload the actual image file
      // For now, we'll just return a placeholder URL
      final ref = storage.ref().child('profile_images/$uid.jpg');
      
      // This is just a placeholder - in a real app, you would upload the image file
      // await ref.putFile(File(imagePath));
      
      final url = await ref.getDownloadURL();
      Logger.info('Profile image uploaded for user: $uid');
      return url;
    } catch (e) {
      Logger.error('Error uploading profile image: $e');
      rethrow;
    }
  }
}