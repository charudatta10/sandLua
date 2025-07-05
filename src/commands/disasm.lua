-- src/commands/disasm.lua
--
-- The 'disasm' command.
--
-- This command reads a file and uses the core disassembler to print its disassembly.

local core_disasm = require("core.disasm")
local helpers = require("utils.helpers")

local cmd = {}

function cmd.run(args)
    if #args < 1 then
        print("Usage: lua-r2 disasm <file_path> [address]")
        return
    end

    local file_path = args[1]
    local address = tonumber(args[2]) or 0

    if not helpers.is_readable(file_path) then
        print("Error: Cannot read file: " .. file_path)
        return
    end

    local file = io.open(file_path, "rb")
    if not file then
        print("Error: Could not open file: " .. file_path)
        return
    end

    local data = file:read("*a")
    file:close()

    core_disasm.disassemble(data, address)
end

return cmd
