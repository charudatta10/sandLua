# src/helpers.py

import os
from typing import List, Optional
from pathlib import Path


class DirectoryScanner:
    """Utility for scanning directories with focused responsibility."""
    
    @staticmethod
    def scan_directory(path: str) -> Optional[List[str]]:
        """Scan directory and return list of entries."""
        try:
            if not os.path.isdir(path):
                print(f"Error: Path is not a directory: {path}")
                return None
            
            return list(os.listdir(path))
        except PermissionError:
            print(f"Error: Permission denied accessing directory: {path}")
            return None
        except Exception as e:
            print(f"Error scanning directory {path}: {e}")
            return None
    
    @staticmethod
    def scan_directory_recursive(path: str, pattern: str = "*") -> List[str]:
        """Recursively scan directory for files matching pattern."""
        try:
            path_obj = Path(path)
            if not path_obj.is_dir():
                print(f"Error: Path is not a directory: {path}")
                return []
            
            return [str(p) for p in path_obj.rglob(pattern) if p.is_file()]
        except Exception as e:
            print(f"Error during recursive scan of {path}: {e}")
            return []


class PathValidator:
    """Utility for path validation with focused responsibility."""
    
    @staticmethod
    def is_valid_file(path: str) -> bool:
        """Check if path is a valid, existing file."""
        return os.path.isfile(path) and os.path.exists(path)
    
    @staticmethod
    def is_valid_directory(path: str) -> bool:
        """Check if path is a valid, existing directory."""
        return os.path.isdir(path) and os.path.exists(path)
    
    @staticmethod
    def normalize_path(path: str) -> str:
        """Normalize a path for consistent handling."""
        return os.path.normpath(os.path.abspath(path))


# Legacy compatibility - maintain the original interface
class Helpers:
    """Legacy helpers class for backward compatibility."""
    
    @staticmethod
    def scandir(path: str) -> List[str]:
        """Legacy method for directory scanning."""
        result = DirectoryScanner.scan_directory(path)
        return result if result is not None else []


# Create instances for backward compatibility
helpers_instance = Helpers()
directory_scanner = DirectoryScanner()
path_validator = PathValidator()
