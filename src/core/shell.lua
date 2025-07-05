local shell = {}
local commands = {}

-- Load commands from the commands directory
local function load_commands()
    local command_files = {
        "disasm",
        "help",
        "hex",
        "load",
        "debug" -- Add the new debug command
    }

    for _, cmd_name in ipairs(command_files) do
        local success, command_module = pcall(require, "src.commands." .. cmd_name)
        if success and command_module then
            commands[cmd_name] = command_module
        else
            io.stderr:write("Error loading command '" .. cmd_name .. "': " .. tostring(command_module) .. "\n")
        end
    end
end

function shell.start()
    load_commands()
    print("SandLua Shell. Type 'help' for a list of commands.")

    while true do
        io.stdout:write("> ")
        local input = io.stdin:read("*l")
        if not input then break end -- EOF

        local args = {}
        for word in input:gmatch("%S+") do
            table.insert(args, word)
        end

        if #args > 0 then
            local cmd_name = args[1]
            local cmd_args = {select(2, unpack(args))}

            if commands[cmd_name] then
                local success, err = pcall(commands[cmd_name].execute, cmd_args)
                if not success then
                    io.stderr:write("Error executing command '" .. cmd_name .. "': " .. tostring(err) .. "\n")
                end
            elseif cmd_name == "quit" or cmd_name == "exit" then
                break
            else
                print("Unknown command: " .. cmd_name .. ". Type 'help' for a list of commands.")
            end
        end
    end
    print("Exiting shell.")
end

return shell