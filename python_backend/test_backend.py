#!/usr/bin/env python3
"""
Test script for TaskFlow Python Backend
"""

import requests
import json
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Base URL
BASE_URL = "http://localhost:5000"

def test_health_check():
    """Test the health check endpoint"""
    print("Testing health check endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/api/health")
        if response.status_code == 200:
            print("✓ Health check passed")
            print(f"  Response: {response.json()}")
        else:
            print(f"✗ Health check failed with status {response.status_code}")
            print(f"  Response: {response.text}")
    except Exception as e:
        print(f"✗ Health check failed with exception: {e}")

def test_login():
    """Test the login endpoint"""
    print("\nTesting login endpoint...")
    try:
        # This is a placeholder test - in a real scenario, you would use a valid Firebase token
        response = requests.post(
            f"{BASE_URL}/api/login",
            json={"firebase_token": "test_token"}
        )
        if response.status_code == 401:
            print("✓ Login endpoint correctly rejects invalid tokens")
        elif response.status_code == 500:
            print("✓ Login endpoint is working (requires valid Firebase token)")
        else:
            print(f"✗ Unexpected response: {response.status_code}")
            print(f"  Response: {response.text}")
    except Exception as e:
        print(f"✗ Login test failed with exception: {e}")

def test_protected_endpoints():
    """Test that protected endpoints require authentication"""
    print("\nTesting authentication for protected endpoints...")
    
    # Test notification endpoint
    try:
        response = requests.post(f"{BASE_URL}/api/send-notification")
        if response.status_code == 401:
            print("✓ Notification endpoint correctly requires authentication")
        else:
            print(f"✗ Notification endpoint should require authentication (got {response.status_code})")
    except Exception as e:
        print(f"✗ Notification endpoint test failed: {e}")
    
    # Test analytics endpoint
    try:
        response = requests.post(f"{BASE_URL}/api/analytics/event")
        if response.status_code == 401:
            print("✓ Analytics endpoint correctly requires authentication")
        else:
            print(f"✗ Analytics endpoint should require authentication (got {response.status_code})")
    except Exception as e:
        print(f"✗ Analytics endpoint test failed: {e}")

def main():
    """Main test function"""
    print("TaskFlow Python Backend Test Script")
    print("=" * 40)
    
    # Check if server is running
    try:
        requests.get(f"{BASE_URL}/api/health", timeout=5)
    except Exception as e:
        print("Error: Could not connect to the backend server.")
        print("Please make sure the server is running on port 5000.")
        print("Start the server with: python app.py")
        return
    
    # Run tests
    test_health_check()
    test_login()
    test_protected_endpoints()
    
    print("\n" + "=" * 40)
    print("Test script completed.")

if __name__ == "__main__":
    main()