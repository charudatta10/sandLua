-- src/core/loader.lua
--
-- Binary loader for lua-r2.
--
-- This module is responsible for identifying and parsing different
-- binary file formats, such as ELF, PE, and Mach-O.

local loader = {}

-- A table to hold the different format-specific loaders
local format_loaders = {
    elf = require("core.formats.elf"),
    pe = require("core.formats.pe"),
    macho = require("core.formats.macho"),
}

-- Tries to identify the binary format based on its magic bytes.
function loader.identify_format(data)
    if #data < 4 then
        return nil -- Not enough data to identify
    end

    local magic = data:sub(1, 4)

    if magic == "\x7fELF" then
        return "elf"
    elseif magic:sub(1, 2) == "MZ" then
        return "pe"
    -- Add more format checks here (e.g., for Mach-O)
    end

    return nil -- Unknown format
end

-- Loads a binary file, identifies its format, and calls the appropriate parser.
function loader.load(binary_path)
    local file = io.open(binary_path, "rb")
    if not file then
        print("Error: Could not open file: " .. binary_path)
        return nil
    end

    local data = file:read("*a")
    file:close()

    local format = loader.identify_format(data)

    if format and format_loaders[format] then
        print("Identified format: " .. format)
        return format_loaders[format].parse(data)
    else
        print("Error: Unknown or unsupported binary format.")
        return nil
    end
end

return loader
