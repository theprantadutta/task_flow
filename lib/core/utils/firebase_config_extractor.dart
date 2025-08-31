import 'dart:io';
import 'dart:convert';
import 'package:task_flow/core/utils/logger.dart';

/// Utility class to extract Firebase configuration from the project
class FirebaseConfigExtractor {
  /// Extract Firebase configuration from firebase_options.dart
  static Future<Map<String, dynamic>?> extractConfig() async {
    try {
      // Path to firebase_options.dart
      final file = File('lib/firebase_options.dart');
      
      if (!await file.exists()) {
        Logger.error('firebase_options.dart not found');
        return null;
      }
      
      final content = await file.readAsString();
      
      // Parse the configuration (simplified implementation)
      // In a real implementation, you would properly parse the Dart file
      final config = <String, dynamic>{};
      
      // Extract project ID
      final projectIdMatch = RegExp(r"projectId: '([^']+)'").firstMatch(content);
      if (projectIdMatch != null) {
        config['projectId'] = projectIdMatch.group(1);
      }
      
      // Extract API key
      final apiKeyMatch = RegExp(r"apiKey: '([^']+)'").firstMatch(content);
      if (apiKeyMatch != null) {
        config['apiKey'] = apiKeyMatch.group(1);
      }
      
      // Extract appId
      final appIdMatch = RegExp(r"appId: '([^']+)'").firstMatch(content);
      if (appIdMatch != null) {
        config['appId'] = appIdMatch.group(1);
      }
      
      // Extract messagingSenderId
      final messagingSenderIdMatch = 
          RegExp(r"messagingSenderId: '([^']+)'").firstMatch(content);
      if (messagingSenderIdMatch != null) {
        config['messagingSenderId'] = messagingSenderIdMatch.group(1);
      }
      
      return config;
    } catch (e) {
      Logger.error('Error extracting Firebase config: $e');
      return null;
    }
  }
  
  /// Generate service account key template for Python backend
  static Future<void> generateServiceAccountTemplate(
      Map<String, dynamic> config) async {
    try {
      final template = {
        'type': 'service_account',
        'project_id': config['projectId'] ?? 'YOUR_PROJECT_ID',
        'private_key_id': 'YOUR_PRIVATE_KEY_ID',
        'private_key': 'YOUR_PRIVATE_KEY',
        'client_email': 'YOUR_CLIENT_EMAIL',
        'client_id': 'YOUR_CLIENT_ID',
        'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
        'token_uri': 'https://oauth2.googleapis.com/token',
        'auth_provider_x509_cert_url': 
            'https://www.googleapis.com/oauth2/v1/certs',
        'client_x509_cert_url': 'YOUR_CLIENT_CERT_URL'
      };
      
      // Write template to python_backend directory
      final outputFile = File('python_backend/serviceAccountKey.json.template');
      await outputFile.writeAsString(
          JsonEncoder.withIndent('  ').convert(template));
      
      Logger.info('Service account key template generated at: ${outputFile.path}');
    } catch (e) {
      Logger.error('Error generating service account template: $e');
    }
  }
}