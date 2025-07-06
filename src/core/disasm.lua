-- src/core/disasm.lua
--
-- The core disassembler module.
--
-- This module uses the Capstone Engine to disassemble code for various architectures.
-- It's designed to be simple and easily extensible for new architectures and modes.

local ffi = require("ffi")
-- Path to cstool.exe (Capstone command-line tool)
local cstool_path = "C:/Users/korde/scoop/apps/capstone/currentcstool.exe"

local capstone = cs

local disasm = {}

-- Default architecture and mode.
-- These can be configured to support different binary types.
local arch = capstone.ARCH_X86
local mode = capstone.MODE_64

-- Initialize the Capstone disassembler.
-- This creates a new Capstone handle with the specified architecture and mode.
local cs = capstone.new(arch, mode)

-- Disassembles a chunk of data at a given address.
--
-- @param data: The raw byte string to be disassembled.
-- @param address: The starting address of the data.
function disasm.disassemble(data, address)
    -- If data is a file path, read the file
    if type(data) == "string" and #data < 4096 and not data:find("[^%w%._%-/\\]") and data:match("%.bin$") then
        local f = io.open(data, "rb")
        if not f then
            print("Error: Could not open file: " .. data)
            return
        end
        data = f:read("*a")
        f:close()
    end

    address = address or 0

    -- Use pcall to catch any errors from the Capstone engine.
    local ok, insns = pcall(function()
        return cs:disasm(data, address)
    end)

    if not ok then
        print("Error: Capstone failed to disassemble the provided data.")
        return
    end

    if #insns == 0 then
        print("--- No instructions found at this address. ---")
        return
    end

    print(string.format("--- Disassembly at 0x%X ---", address))
    for _, insn in ipairs(insns) do
        print(string.format("0x%X:\t%-7s\t%s", insn.address, insn.mnemonic, insn.op_str))
    end
    print("--- End of Disassembly ---")
end

return disasm



