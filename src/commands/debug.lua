local sandbox = require("src.core.sandbox")
local ffi = require("ffi")

local M = {}

function M.run(args)
    if not args[1] then
        print("Usage: debug <path_to_executable>")
        return
    end

    local command_line = args[1]
    local pi = sandbox.create_sandboxed_process(command_line)

    if pi then
        print("Successfully launched process for debugging. Entering debug loop...")
        sandbox.debug_loop(pi)
        ffi.C.CloseHandle(pi.hProcess)
        ffi.C.CloseHandle(pi.hThread)
        print("Exited debug loop. Process handles closed.")
    else
        print("Failed to launch process for debugging.")
    end
end

return M