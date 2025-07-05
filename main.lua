-- main.lua
--
-- Main command dispatcher for lua-r2.
--
-- This script parses command-line arguments, loads the appropriate command
-- from the `src/commands` directory, and executes it.

-- Set a default command for when no arguments are given
local DEFAULT_COMMAND = "help"

-- Get the command and its arguments from the command line
local command_name = arg[1] or DEFAULT_COMMAND
local command_args = {}
for i = 2, #arg do
    table.insert(command_args, arg[i])
end

-- Construct the path to the command module
local command_path = "commands." .. command_name

-- Use pcall to safely load the command module
local ok, command_module = pcall(require, command_path)

if ok then
    -- If the module loaded successfully, run the command
    if command_module and type(command_module.run) == "function" then
        command_module.run(command_args)
    else
        print("Error: Invalid command module for '" .. command_name .. "'.")
        print("The module must return a table with a 'run' function.")
    end
else
    -- If the module failed to load, print an error message
    print("Error: Command not found: " .. command_name)
    -- You can add a 'help' command to list available commands.
end
