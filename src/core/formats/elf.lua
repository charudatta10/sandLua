-- src/core/formats/elf.lua
--
-- ELF binary format parser.
--
-- This module is responsible for parsing the headers, sections,
-- and symbols of an ELF file.

local elf = {}

-- Check if the ELF file is 64-bit
local function is_64_bit(e_ident)
    return e_ident:byte(5) == 2 -- EI_CLASS == ELFCLASS64
end

-- Helper function to unpack data from the ELF file
local function unpack_elf_header(data)
    local e_ident = data:sub(1, 16)
    local is64 = is_64_bit(e_ident)

    -- The ELF header is 52 bytes for 32-bit and 64 bytes for 64-bit
    local expected_size = is64 and 64 or 52
    if #data < expected_size then
        return nil, "Invalid ELF header: not enough data"
    end

    local header_format = is64 and "c16 H H I Q Q Q I H H H H H H" or "c16 H H I I I I I I H H H H H H"
    local _, e_type, e_machine, e_version, e_entry, e_phoff, e_shoff, e_flags, e_ehsize, e_phentsize, e_phnum, e_shentsize, e_shnum, e_shstrndx = string.unpack(
        header_format,
        data
    )

    return {
        e_ident = e_ident,
        e_type = e_type,
        e_machine = e_machine,
        e_version = e_version,
        e_entry = e_entry,
        e_phoff = e_phoff,
        e_shoff = e_shoff,
        e_flags = e_flags,
        e_ehsize = e_ehsize,
        e_phentsize = e_phentsize,
        e_phnum = e_phnum,
        e_shentsize = e_shentsize,
        e_shnum = e_shnum,
        e_shstrndx = e_shstrndx,
    }
end

-- Helper function to unpack a single ELF section header
local function unpack_elf_section_header(data, is64)
    local expected_size = is64 and 64 or 40
    if #data < expected_size then
        return nil, "Invalid ELF section header: not enough data"
    end

    local section_header_format = is64 and "I I Q Q Q Q I I Q Q" or "I I I I I I I I I I"
    local _, sh_name, sh_type, sh_flags, sh_addr, sh_offset, sh_size, sh_link, sh_info, sh_addralign, sh_entsize = string.unpack(
        section_header_format,
        data
    )

    return {
        sh_name = sh_name,
        sh_type = sh_type,
        sh_flags = sh_flags,
        sh_addr = sh_addr,
        sh_offset = sh_offset,
        sh_size = sh_size,
        sh_link = sh_link,
        sh_info = sh_info,
        sh_addralign = sh_addralign,
        sh_entsize = sh_entsize,
    }
end

function elf.parse(data)
    print("Parsing ELF file...")

    local header, err = unpack_elf_header(data)

    if not header then
        print("Error: " .. err)
        return nil
    end

    local is64 = is_64_bit(header.e_ident)
    print(string.format("--- ELF Header (%s) ---", is64 and "64-bit" or "32-bit"))
    for key, value in pairs(header) do
        if type(value) == "number" then
            print(string.format("%-12s: 0x%X", key, value))
        else
            print(string.format("%-12s: %s", key, value))
        end
    end
    print("--- End of ELF Header ---")

    -- Parse the section headers
    local sections = {}
    if header.e_shoff > 0 and header.e_shnum > 0 then
        print("\n--- ELF Section Headers ---")
        local sh_offset = header.e_shoff
        for i = 1, header.e_shnum do
            local section_header_data = data:sub(sh_offset, sh_offset + header.e_shentsize - 1)
            local section_header, section_err = unpack_elf_section_header(section_header_data, is64)
            if not section_header then
                print("Error parsing section header " .. i .. ": " .. section_err)
            else
                table.insert(sections, section_header)
                print(string.format(
                    "  [%2d] Name: 0x%-8X Type: 0x%-8X Addr: 0x%-16X Offset: 0x%-8X Size: 0x%-8X",
                    i - 1,
                    section_header.sh_name,
                    section_header.sh_type,
                    section_header.sh_addr,
                    section_header.sh_offset,
                    section_header.sh_size
                ))
            end
            sh_offset = sh_offset + header.e_shentsize
        end
        print("--- End of ELF Section Headers ---")
    end

    local binary_info = {
        format = "elf",
        header = header,
        sections = sections,
        symbols = {},
    }

    return binary_info
end

return elf

