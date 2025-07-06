# src/base_command.py

import sys
from abc import ABC, abstractmethod
from typing import List, Optional
from file_handler import ArgumentParser, ErrorHandler


class BaseCommand(ABC):
    """Base class for all commands with common functionality."""
    
    def __init__(self, name: str = ""):
        self.name = name
    
    def run(self, args: List[str]) -> None:
        """Execute the command with error handling."""
        try:
            self._execute(args)
        except Exception as e:
            ErrorHandler.handle_command_error(self.name or self.__class__.__name__, e)
    
    @abstractmethod
    def _execute(self, args: List[str]) -> None:
        """Execute the command implementation. Must be overridden by subclasses."""
        pass
    
    def _validate_args(self, args: List[str], min_count: int, usage_msg: str) -> bool:
        """Validate minimum argument count."""
        return ArgumentParser.validate_min_args(args, min_count, usage_msg)
    
    def _parse_address(self, address_str: str, default: int = 0) -> int:
        """Parse address string to integer."""
        return ArgumentParser.parse_address(address_str, default)

