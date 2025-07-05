-- src/commands/hex.lua
--
-- The 'hex' command.
--
-- This command provides a hex dump of a file or a specific range of bytes.

local core_hexview = require("core.hexview")
local helpers = require("utils.helpers")

local cmd = {}

function cmd.run(args)
    if #args < 1 then
        print("Usage: lua-r2 hex <file_path> [offset] [count]")
        return
    end

    local file_path = args[1]
    local offset = tonumber(args[2]) or 0
    local count = tonumber(args[3])

    if not helpers.is_readable(file_path) then
        print("Error: Cannot read file: " .. file_path)
        return
    end

    local file = io.open(file_path, "rb")
    if not file then
        print("Error: Could not open file: " .. file_path)
        return
    end

    file:seek("set", offset)
    local data = file:read(count or "*a")
    file:close()

    if not data or #data == 0 then
        print("No data to display at this offset.")
        return
    end

    core_hexview.dump(data, offset)
end

return cmd