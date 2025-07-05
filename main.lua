-- main.lua
--
-- Main command dispatcher for lua-r2.
--
-- This script parses command-line arguments, loads the appropriate command
-- from the `src/commands` directory, and executes it.

local shell = require("src.core.shell")

-- Get the command and its arguments from the command line
local command_name = arg[1]
local command_args = {}
for i = 2, #arg do
    table.insert(command_args, arg[i])
end

if not command_name then
    -- If no command is provided, start the interactive shell
    shell.start()
else
    -- Otherwise, try to execute the command directly
    local command_path = "src.commands." .. command_name
    local ok, command_module = pcall(require, command_path)

    if ok then
        if command_module and type(command_module.run) == "function" then
            command_module.run(command_args)
        else
            print("Error: Invalid command module for '" .. command_name .. "'.")
            print("The module must return a table with an 'execute' function.")
        end
    else
        print("Error: Command not found: " .. command_name)
    end
end
