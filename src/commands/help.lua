-- src/commands/help.lua
--
-- The 'help' command.
--
-- This command provides a basic help message, listing available commands.

local cmd = {}

function cmd.run(args)
    print("lua-r2: A reverse engineering framework in Lua")
    print("Usage: lua-r2 <command> [args]")
    print("\nAvailable commands:")
    print("  disasm   - Disassemble code")
    print("  help     - Show this help message")
    -- Add more commands here as they are implemented.
end

return cmd
