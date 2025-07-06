import sys
from typing import Dict
from debug import debug_command
from disasm import disasm_command
from help import help_command
from hex import hex_command
from load import load_command
from constants import SHELL_WELCOME, SHELL_PROMPT, SHELL_EXIT, ERR_UNKNOWN_COMMAND
from file_handler import ErrorHandler


class Shell:
    """Interactive shell for SandLua commands."""
    
    EXIT_COMMANDS = {"quit", "exit"}
    
    def __init__(self):
        self.commands: Dict[str, object] = {
            "disasm": disasm_command,
            "help": help_command,
            "hex": hex_command,
            "load": load_command,
            "debug": debug_command,
        }
    
    def start(self) -> None:
        """Start the interactive shell."""
        print(SHELL_WELCOME)
        
        while True:
            try:
                line = input(SHELL_PROMPT)
            except (EOFError, KeyboardInterrupt):
                break  # Handle Ctrl+D and Ctrl+C
            
            if not self._process_input(line):
                break
        
        print(SHELL_EXIT)
    
    def _process_input(self, line: str) -> bool:
        """Process a single line of input. Returns False to exit shell."""
        args = line.strip().split()
        
        if not args:
            return True
        
        cmd_name = args[0]
        cmd_args = args[1:]
        
        if cmd_name in self.EXIT_COMMANDS:
            return False
        
        if cmd_name in self.commands:
            self._execute_command(cmd_name, cmd_args)
        else:
            print(ERR_UNKNOWN_COMMAND.format(cmd_name))
        
        return True
    
    def _execute_command(self, cmd_name: str, cmd_args: list) -> None:
        """Execute a command with error handling."""
        command = self.commands[cmd_name]
        try:
            command.run(cmd_args)
        except Exception as e:
            ErrorHandler.handle_command_error(cmd_name, e)
