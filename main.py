import sys
import os
from pathlib import Path

# Add the project's src directory to the Python path
project_root = Path(__file__).parent
src_path = project_root / 'src'
sys.path.insert(0, str(src_path.resolve()))

from shell import Shell
from constants import APP_NAME


def setup_environment():
    """Setup the application environment."""
    # Ensure we can import from src directory
    if str(src_path) not in sys.path:
        sys.path.insert(0, str(src_path))


def main():
    """Main application entry point."""
    setup_environment()
    
    print(f"Hello from {APP_NAME} (Python)!\n")
    
    shell_instance = Shell()
    shell_instance.start()


if __name__ == "__main__":
    main()
