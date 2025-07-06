# src/load.py

import os
import struct
import pefile
from base_command import BaseCommand

class LoadCommand(BaseCommand):
    def _identify_format(self, binary_path):
        try:
            with open(binary_path, "rb") as f:
                magic = f.read(4)
        except IOError:
            return None

        if not magic or len(magic) < 4:
            return None

        if magic == b"\x7fELF":
            return "elf"
        elif magic.startswith(b"MZ"):
            return "pe"
        elif magic in [b"\xfe\xed\xfa\xce", b"\xce\xfa\xed\xfe",
                       b"\xfe\xed\xfa\xcf", b"\xcf\xfa\xed\xfe"]:
            return "macho"

        return None

    def _elf_is_64_bit(self, e_ident):
        return e_ident[4] == 2

    def _elf_get_endianness_prefix(self, e_ident):
        endianness = e_ident[5]
        if endianness == 1:
            return '<'
        elif endianness == 2:
            return '>'
        else:
            raise ValueError("Unknown ELF data encoding")

    def _elf_unpack_elf_header(self, data):
        if len(data) < 16:
            return None, "Not enough data for e_ident"

        e_ident = data[0:16]
        if e_ident[0:4] != b"\x7fELF":
            return None, "Invalid ELF magic number"

        is_64_bit = self._elf_is_64_bit(e_ident)
        endian_prefix = self._elf_get_endianness_prefix(e_ident)

        if is_64_bit:
            header_format = endian_prefix + '16sHHIIQQQIHHHHHH'
            expected_size = 64
        else:
            header_format = endian_prefix + '16sHHIIIIIIHHHHHH'
            expected_size = 52

        if len(data) < expected_size:
            return None, f"Invalid ELF header: not enough data (expected {expected_size} bytes)"

        try:
            unpacked = struct.unpack_from(header_format, data, 0)
        except struct.error as e:
            return None, f"Struct unpacking error: {e}"

        keys_64 = ["e_ident", "e_type", "e_machine", "e_version", "e_entry", "e_phoff", "e_shoff",
                   "e_flags", "e_ehsize", "e_phentsize", "e_phnum", "e_shentsize", "e_shnum", "e_shstrndx"]
        keys_32 = ["e_ident", "e_type", "e_machine", "e_version", "e_entry", "e_phoff", "e_shoff",
                   "e_flags", "e_ehsize", "e_phentsize", "e_phnum", "e_shentsize", "e_shnum", "e_shstrndx"]

        keys = keys_64 if is_64_bit else keys_32
        header = dict(zip(keys, unpacked))

        return header, None

    def _elf_unpack_elf_section_header(self, data, is_64_bit, endian_prefix):
        if is_64_bit:
            section_header_format = endian_prefix + 'IIQQQQIIQQ'
            expected_size = 64
        else:
            section_header_format = endian_prefix + 'IIIIIIIIII'
            expected_size = 40

        if len(data) < expected_size:
            return None, f"Invalid ELF section header: not enough data (expected {expected_size} bytes)"

        try:
            unpacked = struct.unpack_from(section_header_format, data, 0)
        except struct.error as e:
            return None, f"Struct unpacking error: {e}"

        keys = ["sh_name", "sh_type", "sh_flags", "sh_addr", "sh_offset", "sh_size",
                "sh_link", "sh_info", "sh_addralign", "sh_entsize"]
        section_header = dict(zip(keys, unpacked))

        return section_header, None

    def _parse_elf(self, binary_path):
        print(f"Parsing ELF file: {binary_path}")
        try:
            with open(binary_path, "rb") as f:
                data = f.read()
        except IOError as e:
            return None, f"Error reading file: {e}"

        header, err = self._elf_unpack_elf_header(data)
        if err:
            print(f"Error: {err}")
            return None

        is_64_bit = self._elf_is_64_bit(header["e_ident"])
        endian_prefix = self._elf_get_endianness_prefix(header["e_ident"])

        print(f"--- ELF Header ({'64-bit' if is_64_bit else '32-bit'}) ---")
        for key, value in header.items():
            if isinstance(value, int):
                print(f"{key:<12}: 0x{value:X}")
            elif isinstance(value, bytes):
                print(f"{key:<12}: {value.hex()}")
            else:
                print(f"{key:<12}: {value}")
        print("--- End of ELF Header ---")

        sections = []
        if header["e_shoff"] > 0 and header["e_shnum"] > 0:
            print("\n--- ELF Section Headers ---")
            sh_offset = header["e_shoff"]
            for i in range(header["e_shnum"]):
                section_header_size = header["e_shentsize"]
                section_data = data[sh_offset : sh_offset + section_header_size]
                section_header, section_err = self._elf_unpack_elf_section_header(section_data, is_64_bit, endian_prefix)
                if section_err:
                    print(f"Error parsing section header {i}: {section_err}")
                else:
                    sections.append(section_header)
                    print(f"  [{i:2}] Name: 0x{section_header['sh_name']:<8X} Type: 0x{section_header['sh_type']:<8X} Addr: 0x{section_header['sh_addr']:<16X} Offset: 0x{section_header['sh_offset']:<8X} Size: 0x{section_header['sh_size']:<8X}")
                sh_offset += section_header_size
            print("--- End of ELF Section Headers ---")

        binary_info = {
            "format": "elf",
            "header": header,
            "sections": sections,
            "symbols": {}, # Placeholder for now
        }

        return binary_info

    def _parse_pe(self, binary_path):
        print(f"Parsing PE file: {binary_path}")
        try:
            pe = pefile.PE(binary_path)
        except pefile.PEFormatError as e:
            print(f"Error: Failed to parse PE file: {e}")
            return None

        parsed_info = {
            "sections": [],
            "image_base": pe.OPTIONAL_HEADER.ImageBase,
            "entry_point_rva": pe.OPTIONAL_HEADER.AddressOfEntryPoint,
            "entry_point_absolute": pe.OPTIONAL_HEADER.ImageBase + pe.OPTIONAL_HEADER.AddressOfEntryPoint,
            "text_section_data": None,
            "text_section_virtual_address": None,
            "text_section_virtual_size": None,
            "arch": "unknown",
            "mode": "unknown",
        }

        machine = pe.FILE_HEADER.Machine
        if machine == pefile.MACHINE_TYPE['IMAGE_FILE_MACHINE_I386']:
            parsed_info['arch'] = "x86"
            parsed_info['mode'] = "32"
        elif machine == pefile.MACHINE_TYPE['IMAGE_FILE_MACHINE_AMD64']:
            parsed_info['arch'] = "x86"
            parsed_info['mode'] = "64"
        elif machine == pefile.MACHINE_TYPE['IMAGE_FILE_MACHINE_ARM']:
            parsed_info['arch'] = "arm"
            parsed_info['mode'] = "arm"
        elif machine == pefile.MACHINE_TYPE['IMAGE_FILE_MACHINE_ARM64']:
            parsed_info['arch'] = "arm64"
            parsed_info['mode'] = "default"

        if pe.OPTIONAL_HEADER.Magic == pefile.OPTIONAL_HEADER_MAGIC['PE32']:
            parsed_info['mode'] = "32"
        elif pe.OPTIONAL_HEADER.Magic == pefile.OPTIONAL_HEADER_MAGIC['PE32_PLUS']:
            parsed_info['mode'] = "64"

        text_section = None
        for section in pe.sections:
            name = section.Name.decode('utf-8').strip('\x00')
            parsed_info['sections'].append({
                "name": name,
                "virtual_address": section.VirtualAddress,
                "virtual_size": section.VirtualSize,
                "pointer_to_raw_data": section.PointerToRawData,
                "size_of_raw_data": section.SizeOfRawData,
                "characteristics": section.Characteristics
            })

            is_executable = (section.Characteristics & pefile.SECTION_CHARACTERISTICS['IMAGE_SCN_CNT_CODE']) or \
                            (section.Characteristics & pefile.SECTION_CHARACTERISTICS['IMAGE_SCN_MEM_EXECUTE'])

            if name == ".text" or is_executable:
                text_section = section
                parsed_info['text_section_virtual_address'] = section.VirtualAddress
                parsed_info['text_section_virtual_size'] = section.VirtualSize

        if not text_section:
            print("Warning: Could not find executable code section in PE file.")
            return parsed_info

        if text_section.SizeOfRawData > 0:
            parsed_info['text_section_data'] = pe.get_memory_from_address(text_section.VirtualAddress, text_section.SizeOfRawData)
        else:
            parsed_info['text_section_data'] = b'\x00' * text_section.VirtualSize
            print("Warning: Using zero-filled buffer for section with no raw data")

        return parsed_info

    def _parse_macho(self, binary_path):
        print(f"Parsing Mach-O file: {binary_path}")
        print("Mach-O format not yet supported.")
        return None

    def _load(self, binary_path):
        if not os.path.exists(binary_path):
            print(f"Error: File not found: {binary_path}")
            return None

        file_format = self._identify_format(binary_path)

        if file_format == "elf":
            return self._parse_elf(binary_path)
        elif file_format == "pe":
            return self._parse_pe(binary_path)
        elif file_format == "macho":
            return self._parse_macho(binary_path)
        else:
            print("Error: Unknown or unsupported binary format.")
            return None

    def _execute(self, args):
        if not args:
            print("Usage: load <binary_path>")
            return
        
        binary_path = args[0]
        loaded_info = self._load(binary_path)

        if loaded_info:
            print(f"Successfully loaded: {loaded_info['path']} as {loaded_info['format']}")
        else:
            print(f"Failed to load: {binary_path}")

load_command = LoadCommand()
