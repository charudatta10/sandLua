package.path = package.path .. ";C:/Users/korde/scoop/apps/luarocks/current/rocks/share/lua/5.4/?.lua"
local pe = require("pe-parser")

-- Bit operations compatibility for LuaJIT
local ok, bit = pcall(require, "bit")
if not ok then
    ok, bit = pcall(require, "bit32")
end
if not ok then
    error("Neither 'bit' nor 'bit32' library found. Please install one of them.")
end

-- Helper function to convert hex string to number
local function hex_to_num(s)
    return tonumber(s, 16) or 0
end

-- Parse the PE file
local path = "a.exe"
local obj = pe.parse(path)
assert(obj, "Failed to parse PE file")

-- Print section headers with proper type conversion
print("\nSection Headers:")
for i, s in ipairs(obj.Sections) do
    local name = s.Name:gsub("%z", "")  -- Remove null bytes
    local va = hex_to_num(s.VirtualAddress)
    local vsize = hex_to_num(s.VirtualSize)
    local offset = hex_to_num(s.PointerToRawData)
    local rawsize = hex_to_num(s.SizeOfRawData)
    local chars = hex_to_num(s.Characteristics)
    
    print(string.format("[%d] %-8s RVA: 0x%05X  Size: 0x%05X  Offset: 0x%05X  RawSize: 0x%05X  Flags: 0x%08X",
          i, name, va, vsize, offset, rawsize, chars))
end

-- Find executable section
local text_section
for _, s in ipairs(obj.Sections) do
    local name = s.Name:gsub("%z", "")
    local chars = hex_to_num(s.Characteristics)
    -- Check for executable flag (IMAGE_SCN_CNT_CODE | IMAGE_SCN_MEM_EXECUTE)
    local is_executable = bit.band(chars, 0x20000020) ~= 0
    
    if name == ".text" or is_executable then
        text_section = s
        break
    end
end

assert(text_section, "Could not find executable code section")

-- Extract section data
local offset = hex_to_num(text_section.PointerToRawData)
local size = hex_to_num(text_section.SizeOfRawData)

local section_data
if size > 0 then
    local f = assert(io.open(path, "rb"))
    f:seek("set", offset)
    section_data = f:read(size)
    f:close()
else
    -- If no raw data, use virtual size filled with zeros
    size = hex_to_num(text_section.VirtualSize)
    section_data = string.rep("\0", size)
    print("Warning: Using zero-filled buffer for section with no raw data")
end

-- Save to file
local out = assert(io.open("text.bin", "wb"))
out:write(section_data)
out:close()

-- Calculate entry point
local image_base = hex_to_num(obj.ImageBase)
local entry_rva = hex_to_num(obj.AddressOfEntryPoint)
local entry = image_base + entry_rva

print("\nDisassembly Info:")
print(string.format("ImageBase:     0x%016X", image_base))
print(string.format("EntryPoint RVA: 0x%08X", entry_rva))
print(string.format("Absolute Entry: 0x%016X", entry))
print(string.format("Section Size:   %d bytes (0x%X)", #section_data, #section_data))
print(string.format("Section Range:  0x%08X-0x%08X", 
      hex_to_num(text_section.VirtualAddress),
      hex_to_num(text_section.VirtualAddress) + hex_to_num(text_section.VirtualSize) - 1))

-- Run disassembler with correct syntax for modern Capstone
local cmd = string.format('cstool x64 "text.bin@0x%x"', entry)
print("\nExecuting:", cmd)
os.execute(cmd)