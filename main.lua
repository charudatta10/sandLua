-- main.lua
--
-- Main command dispatcher for lua-r2.
--
-- This script parses command-line arguments, loads the appropriate command
-- from the `src/commands` directory, and executes it.

-- Add current directory to package.path to allow requiring modules from src/
package.path = ";./src/?.lua;./src/?/init.lua;" .. package.path

local shell = require("src.core.shell")

-- Get the command and its arguments from the command line
local command_name
local command_args = {}

if arg[1] == "lua-r2" then
    command_name = arg[2]
    for i = 3, #arg do
        table.insert(command_args, arg[i])
    end
else
    command_name = arg[1]
    for i = 2, #arg do
        table.insert(command_args, arg[i])
    end
end

if not command_name then
    -- If no command is provided, start the interactive shell
    shell.start()
else
    -- Otherwise, try to execute the command directly
    local command_path = "src.commands." .. command_name
    local ok, command_module_or_err = pcall(require, command_path)

    if ok then
        if command_module_or_err then
            if type(command_module_or_err.run) == "function" then
                command_module_or_err.run(command_args)
            elseif type(command_module_or_err.execute) == "function" then
                command_module_or_err.execute(command_args)
            else
                print("Error: Invalid command module for '" .. command_name .. "'.")
                print("The module must return a table with a 'run' or 'execute' function.")
            end
        else
            print("Error: Invalid command module for '" .. command_name .. "'.")
        end
    else
        print("Error loading command '" .. command_name .. "': " .. tostring(command_module_or_err))
    end
end
