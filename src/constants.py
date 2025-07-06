# src/constants.py

# Application constants
APP_NAME = "SandLua"
SHELL_PROMPT = "> "
SHELL_WELCOME = "SandLua Shell. Type 'help' for a list of commands."
SHELL_EXIT = "Exiting shell."

# File format constants
ELF_MAGIC = b"\x7fELF"
PE_MAGIC = b"MZ"
MACHO_MAGIC_32_BE = b"\xfe\xed\xfa\xce"
MACHO_MAGIC_32_LE = b"\xce\xfa\xed\xfe"
MACHO_MAGIC_64_BE = b"\xfe\xed\xfa\xcf"
MACHO_MAGIC_64_LE = b"\xcf\xfa\xed\xfe"

# Binary formats
FORMAT_ELF = "elf"
FORMAT_PE = "pe"
FORMAT_MACHO = "macho"

# Hex view constants
HEX_BYTES_PER_LINE = 16
HEX_ASCII_PRINTABLE_MIN = 32
HEX_ASCII_PRINTABLE_MAX = 126
HEX_ASCII_REPLACEMENT = "."

# ELF constants
ELF_64_BIT_CLASS = 2
ELF_ENDIAN_LITTLE = 1
ELF_ENDIAN_BIG = 2
ELF_HEADER_SIZE_32 = 52
ELF_HEADER_SIZE_64 = 64
ELF_SECTION_HEADER_SIZE_32 = 40
ELF_SECTION_HEADER_SIZE_64 = 64

# Command usage messages
USAGE_DISASM = "Usage: disasm <data_path> [address]"
USAGE_HEX = "Usage: hex <data_path> [address]"
USAGE_LOAD = "Usage: load <binary_path>"
USAGE_DEBUG = "Usage: debug <command_line>"

# Error messages
ERR_UNKNOWN_COMMAND = "Unknown command: {}. Type 'help' for a list of commands."
ERR_FILE_NOT_FOUND = "Error: File not found: {}"
ERR_INVALID_FORMAT = "Error: Unknown or unsupported binary format."
ERR_CAPSTONE_FAILED = "Error: Capstone failed to disassemble the provided data: {}"
ERR_NO_INSTRUCTIONS = "--- No instructions found at this address."

# Debug constants
DEBUG_TIMEOUT = 10
DEBUG_TIMEOUT_MSG = "Process did not terminate within the timeout. Terminating it."
DEBUG_STDOUT_HEADER = "\n--- Process Output (STDOUT) ---"
DEBUG_STDERR_HEADER = "\n--- Process Output (STDERR) ---"
