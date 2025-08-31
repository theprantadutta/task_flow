#!/usr/bin/env python3
"""
Script to extract Firebase configuration from Flutter project
and generate Firebase Admin SDK credentials
"""

import json
import os
import sys

def extract_firebase_config():
    """
    Extract Firebase configuration from Flutter project
    """
    # Path to Flutter project
    flutter_project_path = os.path.join(os.path.dirname(__file__), "..")
    
    # Look for firebase_options.dart file
    firebase_options_path = os.path.join(
        flutter_project_path, "lib", "firebase_options.dart"
    )
    
    if not os.path.exists(firebase_options_path):
        print("firebase_options.dart not found in Flutter project")
        print("Please ensure Firebase is properly configured in your Flutter project")
        return None
    
    # Read firebase_options.dart
    with open(firebase_options_path, 'r') as f:
        content = f.read()
    
    # Extract configuration (this is a simplified example)
    # In a real implementation, you would parse the Dart file properly
    print("Firebase configuration extracted from Flutter project:")
    print("-" * 50)
    print(content)
    print("-" * 50)
    
    # Generate service account key template
    service_account_template = {
        "type": "service_account",
        "project_id": "YOUR_PROJECT_ID",
        "private_key_id": "YOUR_PRIVATE_KEY_ID",
        "private_key": "YOUR_PRIVATE_KEY",
        "client_email": "YOUR_CLIENT_EMAIL",
        "client_id": "YOUR_CLIENT_ID",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "YOUR_CLIENT_CERT_URL"
    }
    
    # Save template
    with open("serviceAccountKey.json.template", 'w') as f:
        json.dump(service_account_template, f, indent=2)
    
    print("\nService account key template created: serviceAccountKey.json.template")
    print("Please replace the placeholder values with your actual Firebase Admin SDK credentials")
    
    return service_account_template

if __name__ == "__main__":
    extract_firebase_config()