# src/help.py

from typing import List
from base_command import BaseCommand


class HelpCommand(BaseCommand):
    """Command for displaying help information."""
    
    HELP_TEXT = [
        "Available commands:",
        "  disasm <data_path> [address] - Disassemble binary data.",
        "  hex <data_path> [address]    - Display hex dump of binary data.",
        "  load <binary_path>           - Load and identify binary file.",
        "  debug <command_line>         - Create and debug a sandboxed process.",
        "  help                         - Show this help message.",
        "  quit / exit                  - Exit the shell."
    ]
    
    def __init__(self):
        super().__init__("help")
    
    def _execute(self, args: List[str]) -> None:
        for line in self.HELP_TEXT:
            print(line)


help_command = HelpCommand()
