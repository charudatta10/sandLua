# src/file_handler.py

import os
import sys
from typing import Optional, Tuple, Union


class FileHandler:
    """Centralized file handling utilities to reduce code duplication."""
    
    @staticmethod
    def read_binary_file(file_path: str) -> Optional[bytes]:
        """Read binary file and return bytes data."""
        try:
            with open(file_path, "rb") as f:
                return f.read()
        except FileNotFoundError:
            print(f"Error: File not found: {file_path}")
            return None
        except PermissionError:
            print(f"Error: Permission denied: {file_path}")
            return None
        except Exception as e:
            print(f"Error reading file {file_path}: {e}")
            return None
    
    @staticmethod
    def validate_file_exists(file_path: str) -> bool:
        """Check if file exists and is a file."""
        if not os.path.exists(file_path):
            print(f"Error: File not found: {file_path}")
            return False
        if not os.path.isfile(file_path):
            print(f"Error: Path is not a file: {file_path}")
            return False
        return True
    
    @staticmethod
    def get_file_data(file_path: str) -> Optional[bytes]:
        """Get file data with validation."""
        if not FileHandler.validate_file_exists(file_path):
            return None
        return FileHandler.read_binary_file(file_path)


class ArgumentParser:
    """Centralized argument parsing utilities."""
    
    @staticmethod
    def parse_address(address_str: str, default: int = 0) -> int:
        """Parse address string to integer."""
        try:
            return int(address_str, 0)
        except ValueError:
            print(f"Warning: Invalid address '{address_str}', using default {default}")
            return default
    
    @staticmethod
    def validate_min_args(args: list, min_count: int, usage_msg: str) -> bool:
        """Validate minimum argument count."""
        if len(args) < min_count:
            print(usage_msg)
            return False
        return True


class ErrorHandler:
    """Centralized error handling utilities."""
    
    @staticmethod
    def handle_command_error(command_name: str, error: Exception) -> None:
        """Handle command execution errors consistently."""
        sys.stderr.write(f"Error executing command '{command_name}': {error}\n")
    
    @staticmethod
    def handle_generic_error(context: str, error: Exception) -> None:
        """Handle generic errors consistently."""
        sys.stderr.write(f"Error in {context}: {error}\n")
