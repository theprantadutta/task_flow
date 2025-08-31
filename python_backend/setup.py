#!/usr/bin/env python3
"""
Setup script for TaskFlow Python Backend
"""

import os
import subprocess
import sys

def create_virtual_environment():
    """Create a Python virtual environment"""
    try:
        subprocess.run([sys.executable, "-m", "venv", "venv"], check=True)
        print("Virtual environment created successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to create virtual environment: {e}")
        return False

def install_dependencies():
    """Install required dependencies"""
    try:
        # Determine the path to pip in the virtual environment
        if os.name == 'nt':  # Windows
            pip_path = os.path.join("venv", "Scripts", "pip")
        else:  # macOS/Linux
            pip_path = os.path.join("venv", "bin", "pip")
        
        subprocess.run([pip_path, "install", "-r", "requirements.txt"], check=True)
        print("Dependencies installed successfully!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to install dependencies: {e}")
        return False

def main():
    """Main setup function"""
    print("Setting up TaskFlow Python Backend...")
    
    # Create virtual environment
    if not create_virtual_environment():
        return False
    
    # Install dependencies
    if not install_dependencies():
        return False
    
    print("\nSetup completed successfully!")
    print("\nTo activate the virtual environment:")
    if os.name == 'nt':  # Windows
        print("  venv\\Scripts\\activate")
    else:  # macOS/Linux
        print("  source venv/bin/activate")
    
    print("\nTo run the server:")
    print("  python app.py")
    
    return True

if __name__ == "__main__":
    main()