-- src/core/disasm.lua
--
-- The core disassembler module.
--
-- This module uses the Capstone Engine to disassemble code for various architectures.
-- It's designed to be simple and easily extensible for new architectures and modes.

-- We are using LuaJIT's FFI to interface with the Capstone library.
-- This requires the Capstone library to be installed on the system.
local ffi = require("ffi")
local capstone = require("capstone")

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

