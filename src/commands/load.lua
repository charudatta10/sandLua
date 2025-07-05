-- src/commands/load.lua
--
-- The 'load' command.
--
-- This command loads a binary file and displays its format information.

local loader = require("core.loader")

local cmd = {}

function cmd.run(args)
    if #args < 1 then
        print("Usage: lua-r2 load <file_path>")
        return
    end

    local file_path = args[1]

    local binary_info = loader.load(file_path)

    if not binary_info then
        print("Failed to load binary file.")
    end
end

return cmd