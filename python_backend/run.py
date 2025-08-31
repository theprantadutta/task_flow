#!/usr/bin/env python3
"""
Script to run the TaskFlow Python Backend
"""

import os
import subprocess
import sys

def check_virtual_environment():
    """Check if virtual environment is activated"""
    return hasattr(sys, 'real_prefix') or (
        hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix
    )

def activate_virtual_environment():
    """Activate virtual environment if not already activated"""
    if not check_virtual_environment():
        print("Virtual environment not activated. Attempting to activate...")
        
        if os.name == 'nt':  # Windows
            activate_script = os.path.join("venv", "Scripts", "activate.bat")
        else:  # macOS/Linux
            activate_script = os.path.join("venv", "bin", "activate")
        
        if os.path.exists(activate_script):
            print(f"Please activate the virtual environment by running:")
            print(f"  {activate_script}")
            print("Then run this script again.")
            return False
        else:
            print("Virtual environment not found. Please run setup.py first.")
            return False
    
    return True

def run_server():
    """Run the Flask server"""
    try:
        # Set environment variables
        os.environ['FLASK_APP'] = 'app.py'
        os.environ['FLASK_ENV'] = 'development'
        
        # Run the Flask app
        subprocess.run([sys.executable, "-m", "flask", "run", "--host=0.0.0.0", "--port=5000"], 
                      check=True)
    except subprocess.CalledProcessError as e:
        print(f"Failed to start server: {e}")
        return False
    except KeyboardInterrupt:
        print("\nServer stopped.")
        return True

def main():
    """Main function"""
    print("Starting TaskFlow Python Backend...")
    
    # Check if virtual environment is activated
    if not activate_virtual_environment():
        return False
    
    # Run the server
    return run_server()

if __name__ == "__main__":
    main()