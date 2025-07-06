# src/hex.py

from typing import List
from base_command import BaseCommand
from file_handler import FileHandler
from constants import USAGE_HEX, HEX_BYTES_PER_LINE, HEX_ASCII_PRINTABLE_MIN, HEX_ASCII_PRINTABLE_MAX, HEX_ASCII_REPLACEMENT


class HexView:
    """Hex dump viewer with clean, focused responsibility."""
    
    def __init__(self, bytes_per_line: int = HEX_BYTES_PER_LINE):
        self.bytes_per_line = bytes_per_line
    
    def dump(self, data: bytes, address: int = 0) -> None:
        """Display hex dump of binary data."""
        for i in range(0, len(data), self.bytes_per_line):
            chunk = data[i:i + self.bytes_per_line]
            offset = address + i
            
            hex_line = self._format_hex_line(chunk, offset)
            print(hex_line)
    
    def _format_hex_line(self, chunk: bytes, offset: int) -> str:
        """Format a single hex line with offset, hex bytes, and ASCII."""
        hex_part = self._format_hex_bytes(chunk)
        ascii_part = self._format_ascii_bytes(chunk)
        return f"0x{offset:08X}: {hex_part:<48} {ascii_part}"
    
    def _format_hex_bytes(self, chunk: bytes) -> str:
        """Format bytes as hex string."""
        return ' '.join(f"{byte:02X}" for byte in chunk)
    
    def _format_ascii_bytes(self, chunk: bytes) -> str:
        """Format bytes as ASCII string with non-printable replacement."""
        return ''.join(
            chr(byte) if HEX_ASCII_PRINTABLE_MIN <= byte <= HEX_ASCII_PRINTABLE_MAX 
            else HEX_ASCII_REPLACEMENT 
            for byte in chunk
        )


class HexCommand(BaseCommand):
    """Command for displaying hex dump of binary files."""
    
    def __init__(self):
        super().__init__("hex")
        self.hex_view = HexView()
    
    def _execute(self, args: List[str]) -> None:
        if not self._validate_args(args, 1, USAGE_HEX):
            return
        
        data_path = args[0]
        address = self._parse_address(args[1]) if len(args) > 1 else 0
        
        data = FileHandler.get_file_data(data_path)
        if data is not None:
            self.hex_view.dump(data, address)


hex_command = HexCommand()
