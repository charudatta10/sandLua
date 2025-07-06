# src/disasm.py

from typing import List, Optional
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
from base_command import BaseCommand
from file_handler import FileHandler
from constants import USAGE_DISASM, ERR_CAPSTONE_FAILED, ERR_NO_INSTRUCTIONS


class Disassembler:
    """Disassembler with focused responsibility for code disassembly."""
    
    def __init__(self, arch=CS_ARCH_X86, mode=CS_MODE_64):
        self.cs = Cs(arch, mode)
    
    def disassemble(self, data: bytes, address: int = 0) -> Optional[List[str]]:
        """Disassemble binary data and return formatted lines."""
        if not isinstance(data, bytes):
            print("Error: Data must be bytes.")
            return None
        
        instructions = self._get_instructions(data, address)
        if instructions is None:
            return None
        
        if not instructions:
            print(ERR_NO_INSTRUCTIONS)
            return []
        
        return self._format_instructions(instructions, address)
    
    def _get_instructions(self, data: bytes, address: int):
        """Get instructions from capstone disassembler."""
        try:
            return list(self.cs.disasm(data, address))
        except Exception as e:
            print(ERR_CAPSTONE_FAILED.format(e))
            return None
    
    def _format_instructions(self, instructions, address: int) -> List[str]:
        """Format instructions into readable output."""
        lines = [f"--- Disassembly at 0x{address:X} ---"]
        
        for insn in instructions:
            line = f"0x{insn.address:X}:\t{insn.mnemonic:<7}\t{insn.op_str}"
            lines.append(line)
        
        lines.append("--- End of Disassembly ---")
        return lines
    
    def print_disassembly(self, data: bytes, address: int = 0) -> None:
        """Disassemble and print results."""
        lines = self.disassemble(data, address)
        if lines is not None:
            for line in lines:
                print(line)


class DisasmCommand(BaseCommand):
    """Command for disassembling binary files."""
    
    def __init__(self):
        super().__init__("disasm")
        self.disassembler = Disassembler()
    
    def _execute(self, args: List[str]) -> None:
        if not self._validate_args(args, 1, USAGE_DISASM):
            return
        
        data_path = args[0]
        address = self._parse_address(args[1]) if len(args) > 1 else 0
        
        data = FileHandler.get_file_data(data_path)
        if data is not None:
            self.disassembler.print_disassembly(data, address)


disasm_command = DisasmCommand()
