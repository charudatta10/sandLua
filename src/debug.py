# src/debug.py

import subprocess
from typing import List, Optional
from base_command import BaseCommand
from constants import USAGE_DEBUG, DEBUG_TIMEOUT, DEBUG_TIMEOUT_MSG, DEBUG_STDOUT_HEADER, DEBUG_STDERR_HEADER


class ProcessManager:
    """Manages process creation and execution."""
    
    def create_process(self, command_line: str) -> Optional[subprocess.Popen]:
        """Create a new process with the given command line."""
        print(f"Attempting to create sandboxed process with command: {command_line}")
        try:
            process = subprocess.Popen(
                command_line, 
                shell=True, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE
            )
            print(f"Process created with PID: {process.pid}")
            return process
        except Exception as e:
            print(f"Failed to create process. Error: {e}")
            return None
    
    def execute_with_timeout(self, process: subprocess.Popen, timeout: int = DEBUG_TIMEOUT) -> None:
        """Execute process with timeout handling."""
        print("Starting placeholder debug loop. Full debugging requires platform-specific APIs.")
        try:
            stdout, stderr = process.communicate(timeout=timeout)
            self._print_process_output(stdout, stderr, process.returncode)
        except subprocess.TimeoutExpired:
            self._handle_timeout(process)
        except Exception as e:
            print(f"Error during debug loop: {e}")
    
    def _print_process_output(self, stdout: bytes, stderr: bytes, return_code: int) -> None:
        """Print process output in a formatted way."""
        print(DEBUG_STDOUT_HEADER)
        print(stdout.decode())
        print(DEBUG_STDERR_HEADER)
        print(stderr.decode())
        print(f"Process exited with code: {return_code}")
    
    def _handle_timeout(self, process: subprocess.Popen) -> None:
        """Handle process timeout by terminating and collecting output."""
        print(DEBUG_TIMEOUT_MSG)
        process.kill()
        stdout, stderr = process.communicate()
        self._print_process_output(stdout, stderr, process.returncode)


class Sandbox:
    """Sandbox for running processes in a controlled environment."""
    
    def __init__(self):
        self.process_manager = ProcessManager()
    
    def run_command(self, command_line: str) -> None:
        """Run a command in the sandbox."""
        process = self.process_manager.create_process(command_line)
        if process:
            self.process_manager.execute_with_timeout(process)


class DebugCommand(BaseCommand):
    """Command for debugging processes in a sandbox."""
    
    def __init__(self):
        super().__init__("debug")
        self.sandbox = Sandbox()
    
    def _execute(self, args: List[str]) -> None:
        if not self._validate_args(args, 1, USAGE_DEBUG):
            return
        
        command_line = " ".join(args)
        self.sandbox.run_command(command_line)


debug_command = DebugCommand()
